function [correct_percentage, suboptimal_percentage, incorrect_percentage, runInfo] = ...
  mdsAirRun (indexGraph, numberRepeats, n, rho)

pkg load io;
[N, mds] = chooseGraph (indexGraph);
runInfo = [];
correct = 0;
subopt = 0;
incorrect = 0;
for indexRepeat = 1 : numberRepeats
  [vec, pStat] = simulateDomsetAirflowBees (N, n, rho);
  [cor, sub, inc] = calculateStats (vec, N, mds);
  correct = correct + (cor > 0);
  subopt = subopt + (sub > 0);
  incorrect = incorrect + (inc > 0);
  timestamp = time ();
  repeatInfo = horzcat ([indexRepeat n rho timestamp (cor > 0) (sub > 0) (inc > 0)], vec (end,:));
  runInfo = [runInfo ; repeatInfo];
end
correct_percentage = 100 * correct / numberRepeats;
suboptimal_percentage = 100 * subopt / numberRepeats;
incorrect_percentage = 100 * incorrect / numberRepeats;
filename = sprintf ("results-air-graph_%d.csv", indexGraph);
cell2csv (filename, mat2cell (runInfo, ones (1, numberRepeats), ones (1, 7 + size (N, 1))));

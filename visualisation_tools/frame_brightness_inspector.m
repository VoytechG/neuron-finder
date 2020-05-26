p = 1;
q = 200;

prctile_p = 1;
prctile_q = 99;
M = movie;
[mins, maxs, avgs] = getStats(M, p, q);
sds = getSDS(M, avgs, p, q);
prctiles_low = getPrctiles(M, p, q, prctile_p);
prctiles_high = getPrctiles(M, p, q, prctile_q);

plot(p:q, avgs(p:q), p:q, maxs(p:q), p:q, mins(p:q), ...
    p:q, sds, ...
    p:q, ones(q - p + 1, 1) * mean(mins), ...
    p:q, ones(q - p + 1, 1) * mean(maxs), ...
    p:q, prctiles_low, ...
    p:q, prctiles_high, ...
    'LineWidth', 1);

legend({'Avg brightness', 'Max birghtness', 'Min brightness', ...
    'Std deviation of brightness', ...
    'Mean max brighntess (whole vid)', ...
    'Mean min brightness (whole vid)', ...
    prctile_p + "th percentile of brightness", ...
    prctile_q + "th percentile of brightness"}, ...
    'Location', 'bestoutside');

disp("Mean mins: " + mean(mins));
disp("Mean maxs: " + mean(maxs));

disp("Mean " + prctile_p + "th percentile: " + mean(prctiles_low));
disp("Mean " + prctile_q + "th percentile: " + mean(prctiles_high));

function [mins, maxs, avgs] = getStats(M, min_x, max_x)
    disp("Getting stats")
    t = cputime;

    elems = max_x - min_x + 1;

    mins = zeros(elems, 1);
    maxs = zeros(elems, 1);
    avgs = zeros(elems, 1);

    for i = 1:elems
        frame = M(:, :, i + min_x - 1);
        mins(i) = min(frame, [], "all");
        maxs(i) = max(frame, [], "all");
        avgs(i) = mean(frame, "all");
    end

    disp("stats calculated in " + (cputime - t));
end

function SD = calcSD(A, avg)

    [w, h] = size(A);
    s = 0;

    for i = 1:w

        for j = 1:h
            s = s + (A(i, j) - avg)^2;
        end

    end

    SD = (s / (w * h))^0.5;
end

function sds = getSDS(M, avgs, min_x, max_x)
    disp("Getting std devs");
    t = cputime;

    sds = zeros(max_x - min_x, 1);

    for i = min_x:max_x
        frame = M(:, :, i + min_x - 1);
        avg = avgs(i);
        sds(i) = calcSD(frame, avg);
    end

    disp("Std devs calculated in " + (cputime - t));
end

function prctiles = getPrctiles(M, min_x, max_x, prctile_val)
    disp("Getting " + prctile_val + "th percentile");
    t = cputime;

    elems = max_x - min_x + 1;

    prctiles = zeros(elems, 1);

    for i = 1:elems
        frame = M(:, :, i + min_x - 1);
        prctiles(i) = prctile(frame, prctile_val, 'all');
    end

    disp("Prctile " + prctile_val + " calculated in " + (cputime - t));
end

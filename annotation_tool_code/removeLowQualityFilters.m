function cellsToSkip = removeLowQualityFilters(p, events)

  [ areas,centroids,~,~,outlines ] = getFilterProps( filters );

  filtersWithAreasTooSmall = areas <= p.annotation.areaThresh;
  filtersWithNoEvents = cellfun(@(x) isempty(x), events);
  cellsToSkip = filtersWithNoEvents | filtersWithAreasTooSmall;
end
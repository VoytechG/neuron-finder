function value = limitValue(value, Min, Max)
  value = min(value, Max);
  value = max(value, Min);
end
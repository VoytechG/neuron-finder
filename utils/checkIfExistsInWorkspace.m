function exists = checkIfExistsInWorkspace(varName)
    checkCommand = sprintf('exist(''%s'',''var'') == 1', varName);
    exists = evalin( 'base', checkCommand );
end
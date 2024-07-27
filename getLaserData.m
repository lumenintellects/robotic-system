function laserData = getLaserData(sim)
    packedData = sim.getStringSignal('laserData');
    if isempty(packedData)
        laserData = [];
    else
        laserData = sim.unpackFloatTable(packedData);
        if iscell(laserData)
            % Extract numeric values from cells and convert to double
            laserData = cellfun(@(x) double(x), laserData, 'UniformOutput', true);
        end
    end
end

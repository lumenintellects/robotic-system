function VisualizeOccupancyGrid(occupancyGrid, handles)
    % VISUALIZEOCCUPANCYGRID Displays the occupancy grid in the specified axes
    %
    % Inputs:
    %   occupancyGrid - the occupancy grid to be displayed
    %   handles - the handles structure containing the GUI components
    %
    % This function updates the axes specified by 'handles.axesOccupancyGrid'
    % to display the current state of the occupancy grid.

    % Select the axes for occupancy grid visualization
    axes(handles.axesOccupancyGrid);
    
    % Display the occupancy grid as an image
    imagesc(occupancyGrid);
    
    % Set the color map to gray
    colormap(gray);
    
    % Ensure the axes have equal scaling
    axis equal;
    
    % Update the display
    drawnow;
end
% This program creates 3D polygons in KMZ for google earth

fclose('all');
clear;
clc;

%myFcn(1);

files = ['che_0001.nc'];
%{
files = ['Dorch_12_0001.nc'; ... 
         'Dorch_12_0002.nc'];
%}
   
tStart = tic;

%% Configuarations
model        = 'fvcom';         % name of used model
percentDisp  = 0.5;
colors       = 1;               % number of colors
scale        = 10;
transparency = 0.6;             % transparency
drawBoundary = 1;               % 1 - draw boundary       0 - don't draw boundary
action       = 'save';
lineWidth    = 0;
altitudeMode = 'absolute';
%altitudeMode = 'relativeToGround';

% Area
area         = 'DORCH';
lon1         = 283.5;
lon2         = 284.2;
lat1         = 38.15;
lat2         = 38.65;

maxZ2Disp    = 1;               % set 99 to find the max value by program
minZ2Disp    = -0.3;            % set -99 to find the min value by program
minWater     = -5;

% File
firstFile    = 1;               % index of the first file
lastFile     = 1;               % index of the last file
kmzCounter   = 1;
startT       = 1;

numOfFiles   = lastFile - firstFile + 1;

%% Validation

% validate num of files
if firstFile > size (files, 1)
    disp('Wrong number for first file');
    return;
end

if lastFile > size (files, 1)
    disp('Wrong number for last file');
    return;
end

% 'other' is reserved for future model
if (~strcmp(model,'fvcom') && ~strcmp(model,'other'))
    disp('Unknown model');
    return;
end


%% Read Data (same for every file)
% Open the first file
ncid = netcdf.open(files(1,:), 'NOWRITE');

latid  = netcdf.inqVarID(ncid, 'lat');
lonid  = netcdf.inqVarID(ncid, 'lon');
latcid = netcdf.inqVarID(ncid, 'latc');
loncid = netcdf.inqVarID(ncid, 'lonc');
vtid   = netcdf.inqVarID(ncid, 'nv');
hid    = netcdf.inqVarID(ncid, 'h');
timeid = netcdf.inqVarID(ncid, 'Times');

% get vertices coordinates
lat   = netcdf.getVar(ncid, latid);
lon   = netcdf.getVar(ncid, lonid);
latc  = netcdf.getVar(ncid, latcid);
lonc  = netcdf.getVar(ncid, loncid);
vt    = netcdf.getVar(ncid, vtid);
h     = netcdf.getVar(ncid, hid);
times = netcdf.getVar(ncid, timeid);

numOfCells     = length(vt);
zRange         = maxZ2Disp - minZ2Disp;

%% Find nodes and cells

latCell = find(latc <= lat2 & latc >= lat1);
lonCell = find(lonc <= lon2 & lonc >= lon1);

area2Disp = intersect(latCell, lonCell);

node2Disp = zeros(3*length(area2Disp), 1, 'int32');

for j = 0:length(area2Disp)-1
    node2Disp(1+j*3) = vt(area2Disp(j+1),1);
    node2Disp(2+j*3) = vt(area2Disp(j+1),2);
    node2Disp(3+j*3) = vt(area2Disp(j+1),3);
end

node2Disp = unique(node2Disp);


%% Write information to txt file
setupFile = strcat(area, '.txt');
fileID = fopen(setupFile, 'w');
fprintf(fileID, '%3.10f %3.10f %3.10f %3.10f\r\n', ...
    lon1, lon2, lat1, lat2);


%% Generate KMZ files
nowTime    = 0;
minZ       = 0;
maxZ       = 0;
totalTimes = [];
startT1    = startT;

for fnums = firstFile:lastFile
    % read zeta and wet_cells from each files (data vary in differnt file)  
    
    infile = files(fnums,:);
    
    ncid   = netcdf.open(infile, 'NOWRITE');   
    
    % find zeta in inundation area
    zetaid = netcdf.inqVarID(ncid, 'zeta');
    zeta   = netcdf.getVar(ncid, zetaid);
    zeta   = zeta';
    
    % find wet cells
    wcid   = netcdf.inqVarID(ncid, 'wet_cells');
    wc     = netcdf.getVar(ncid, wcid);
    wc     = wc';
    
    % load time
    timeid = netcdf.inqVarID(ncid, 'Times');
    times  = netcdf.getVar(ncid, timeid);
    times  = times';
    times  = times(:,1:19);
    
    totalTimes = vertcat(totalTimes, times);
    
    msg = sprintf('Processing %s ... (%d/%d)', ...
                  infile, fnums, lastFile-firstFile+1);
    disp(msg);
    
    for t = startT:size(times,1)
        outfile = sprintf('%s_%d', area, kmzCounter);
        
        % Create a new kml object
        kmz = kml(outfile);
        
        msg = sprintf('Creating %s.kmz (%s) ...', outfile, times(t,:));
        disp(msg);   
        
        dryCells = find(wc(t,:) == 0);
        
        cell2Disp = setdiff(area2Disp, dryCells);
        
        numOfCell2Disp = length(cell2Disp);
        
        ignoreCells = [];
        cellColors  = [];
        colorIndex  = [];
                              
        % draw inundation polygons
        for i = 1:numOfCell2Disp
            
            node1 = vt(cell2Disp(i,:), 1);
            node2 = vt(cell2Disp(i,:), 2);
            node3 = vt(cell2Disp(i,:), 3);
            
            land = 0;
            
            if h(node1) < 0
                land = land + 1;
                z1 = zeta(t,node1) + h(node1);
            else
                z1 = zeta(t,node1);
            end
            
            if h(node2) < 0
                land = land + 1;
                z2 = zeta(t,node2) + h(node2);
            else
                z2 = zeta(t,node2);
            end
            
            if h(node3) < 0
                land = land + 1;
                z3 = zeta(t,node3) + h(node3);
            else
                z3 = zeta(t,node3);
            end
            
            if land == 3 && (z1 <=minWater || z2 <= minWater || z3 <= minWater)
                ignoreCells = horzcat(ignoreCells, i);
                continue;   
            end
            
            minZ = min([minZ z1 z2 z3]);
            maxZ = max([maxZ z1 z2 z3]);            
            
            % average water level
            avgZ = (z1+z2+z3)/3;
            
            % color options
            if colors == 2
                if avgZ >= zRange*percentDisp
                    color = num2ARGB(0, 0, 1, transparency);
                    cellColors = vertcat(cellColors, color);
                else
                    color = num2ARGB(0, 1, 0, transparency);
                    cellColors = vertcat(cellColors, color);
                end
            elseif colors == 1
                color = num2color((avgZ-minZ2Disp)/zRange, transparency);
                cellColors = vertcat(cellColors, color);
            end
            
            % round to 2 decimal
            z1 = round(z1*100)/100;
            z2 = round(z2*100)/100;
            z3 = round(z3*100)/100;
            
            % don't draw underground polygon 
            if z1 < 0; z1 = 0; end
            if z2 < 0; z2 = 0; end
            if z3 < 0; z3 = 0; end
            
            name = strcat('Cell ID: ', num2str(cell2Disp(i)));
            
            description = ['<style type=', char(34), 'text/css', char(34), '>', ...
                'table.myTable { border-collapse:collapse; width:300px}', ...
                'table.myTable td { border:1px solid black; background: #e1e1e1;}', ...
                '</style>', ...
                '<table class=', char(34), 'myTable', char(34), '>', ...
                '<tr><td><b>Average Water Level: </b></td>', ...
                '<td>', num2str(avgZ,2), ' m</td></tr>', ...
                '<tr><td><b>Time: </b></td>', ...
                '<td>', times(t,:), '</td></tr>', ...
                '</table>'];
            
            try                
                kmz.poly3([lon(node1) lon(node2) lon(node3) lon(node1)], ...
                    [lat(node1) lat(node2) lat(node3) lat(node1)], ...
                    [z1 z2 z3 z1]*scale, ...
                    'name', name, ...
                    'description', description, ...
                    'polyColor',color, ...
                    'lineWidth',lineWidth, ...
                    'altitudeMode',altitudeMode);
            catch ex
                kmz.clear;
                disp(ex.identifier);
                disp('Exiting...');
                return;
            end           
        end   
        
        if drawBoundary == 1
            % ignore cells which are lower than minWater
            cell2Disp(ignoreCells) = [];
                        
            numOfWetCells = length(cell2Disp);
            
            tvt = vt(cell2Disp,:);
            tvt = sort(tvt, 2);
            boundary = zeros(3*numOfWetCells, 3, 'int32');
            
            for v = 0:(numOfWetCells-1)
                boundary(v*3+1,:) = [tvt(v+1,1) tvt(v+1,2) cell2Disp(v+1)];
                boundary(v*3+2,:) = [tvt(v+1,2) tvt(v+1,3) cell2Disp(v+1)];
                boundary(v*3+3,:) = [tvt(v+1,1) tvt(v+1,3) cell2Disp(v+1)];
            end
            
            vSize = size(boundary,1);
            
            b = 1;
            
            while b <= vSize
                index = find(boundary(:, 1) == boundary(b,1) & boundary(:, 2) == boundary(b,2));
                if size(index,1) == 2
                    boundary(index(1),:) = [];
                    boundary(index(2)-1,:) = [];
                    vSize = size(boundary,1);
                else
                    b = b + 1;
                end
            end
            
            numOfEdges = size(boundary,1);
            
            % longitudes and latitudes of the boundary
            blon = zeros(numOfEdges, 2, 'double');
            blat = zeros(numOfEdges, 2, 'double');
            
            for e = 1:numOfEdges
                blon(e,:) = lon(boundary(e,1:2));
                blat(e,:) = lat(boundary(e,1:2));
            end
            
            for k = 1:size(boundary,1)
                
                ind1 = boundary(k,1);
                ind2 = boundary(k,2);
                
                % calculate z1 and z2
                if h(ind1) < 0
                    z1 = zeta(t,ind1) + h(ind1);
                else
                    z1 = zeta(t,ind1);
                end
                
                if h(ind2) < 0
                    z2 = zeta(t,ind2) + h(ind2);
                else
                    z2 = zeta(t,ind2);
                end
                
                % round to 2 decimal
                z1 = round(z1*100)/100;
                z2 = round(z2*100)/100;
                
                % only draw border for polyons above the ground
                if z1 > 0 && z2 > 0                 
                    edgeColor = cellColors(cell2Disp == boundary(k,3), :);                    
                    kmz.poly3(blon(k,:), blat(k,:), ...
                        [z1 z2]*scale, ...
                        'polyColor',edgeColor, ...
                        'lineWidth',0, ...
                        'altitudeMode',altitudeMode, ...
                        'extrude',true);
                end
            end
        end
        
        % run or save KMZ files
        if strcmp(action,'save')
            kmz.save;
        else
            kmz.run;
        end
        kmz.clear;
        
        kmzCounter = kmzCounter+1;
                
        lastTime = nowTime;
        nowTime = toc(tStart);
        tElapsed = nowTime - lastTime;
        msg = sprintf('Elaped time: %s  Total time: %s', ... 
                      datestr(datenum(0,0,0,0,0,tElapsed),'HH:MM:SS'), ...
                      datestr(datenum(0,0,0,0,0,nowTime),'HH:MM:SS'));
        disp(msg);        
    end
    
    startT = 1;
end


fprintf(fileID, '%1.4f %1.4f\r\n', minZ, maxZ);

fprintf(fileID, '%d\r\n', kmzCounter - 1);

for t = startT1:length(totalTimes)
    fprintf(fileID, '%s\r\n', totalTimes(t,:));
end

fclose(fileID);

tElapsed = toc(tStart);
msg = sprintf('Total time: %s', datestr(datenum(0,0,0,0,0,tElapsed),'HH:MM:SS'));
disp(msg);
disp('done!');
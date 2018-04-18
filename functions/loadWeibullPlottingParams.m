function [xUnits, colors, labels] = loadWeibullPlottingParams(expName)

% Define Weibull plotting parameters for a specific experiment

%       [xUnits, colors, labels] = loadWeibullPlottingParams(expName)

% INPUTS: 
%   expName        : String defining which type of experiment parameters to use. 
%                       Choose from 'default',
%                                   'eyemov',
%                                   'eyemovEnhanced',
%                                   'coneDensity',
%                                   'defocus',
%                                   'ConeTypes',
%                     (default= 'default')

%% Check input arguments
if isempty(expName) || ~exist('expName', 'var')
    expName = 'default'; 
end

% Get general condition parameters
expParams                = loadExpParams(expName, false);

% Define plotting parameters
switch lower(expName)
    case 'default'
        colors              = [0 0 0];
        labels              = {'Fit','data'};
        xUnits          = expParams.contrastLevels;
        
    case 'conetypes'
        colors              = {'k','r','g','b'};
        labels              = {'LMS cones','', ...
            'L cones','', ...
            'M cones','', ...
            'S cones',''};
        xUnits          = expParams.contrastLevels;
        
    case 'eyemov'
        colors              = copper(size(expParams.eyemovement,2));
        labels              = cell(1,length(colors));
        for emIdx = 1:length(colors)
            thisCondition = expParams.eyemovement(:,emIdx)';
            if all(thisCondition == [0 0 0])
                labels{:,emIdx} = 'No eyemovements';
            elseif  all(thisCondition == [1 0 0])
                labels{:,emIdx} = 'Tremor';
            elseif  all(thisCondition == [0 1 0])
                labels{:,emIdx} = 'Drift';
            elseif  all(thisCondition == [1 1 0])
                labels{:,emIdx} = 'Tremor+Drift';
            elseif  all(thisCondition == [0 0 1])
                labels{:,emIdx} = 'Microsaccades';
            end
        end
        xUnits          = expParams.contrastLevels;
        
    case 'eyemovenhanced'
        colors              = copper(size(expParams.eyemovement,2));
        labels              = cell(1,length(colors));
        for emIdx = 1:length(colors)
            thisCondition = expParams.eyemovement(:,emIdx)';
            if all(thisCondition == [0 0 0])
                labels{:,emIdx} = 'No eyemovements';
            elseif  all(thisCondition == [2 0 0])
                labels{:,emIdx} = '2xTremor';
            elseif  all(thisCondition == [0 2 0])
                labels{:,emIdx} = '2xDrift';
            elseif  all(thisCondition == [2 2 0])
                labels{:,emIdx} = '2xTremor+Drift';
            elseif  all(thisCondition == [0 0 2])
                labels{:,emIdx} = '2xMicrosaccades';
            end
        end
        
    case {'conedensity','conedensitynoeyemov'}
        
        colors              = jet(length(expParams.eccentricities));
        
        % Change x labels to density
        whichEye          = 'left';
        cparams.cmFOV     =  1; % degrees
        
        % Convertion deg to m
        deg2m  = 0.3 * 0.001; % .3 deg per mm, .001 mm per meter
        
        % Predefine density vector
        allDensity = nan(length(expParams.eccentricities),1);
        labels = cell(length(expParams.eccentricities),1);
        
        for ec = expParams.eccentricities
            % Specify retinal location where stimulus is presented
            cparams.eccentricity = ec;                     % Visual angle of stimulus center, in deg
            cparams.polarAngle   = expParams.polarAngle;   % Polar angle (radians): 0 is right, pi/2 is superior, pi is left, 3*pi/2 inferior
            
            % Compute x,y position in m of center of retinal patch from ecc and angle
            [x, y] = pol2cart(cparams.polarAngle, cparams.eccentricity);
            x = x * deg2m;  y = y * deg2m;
            cMosaic = coneMosaic('center', [x, y], 'whichEye', whichEye);
            
            % Set the field of view (degrees)
            cMosaic.setSizeToFOV(cparams.cmFOV);
            allDensity(ec==expParams.eccentricities,:) = eccen2density(cMosaic, 'mm');
            
            labels{ec==expParams.eccentricities} = sprintf('%1.3f x10^5 cells/mm2', allDensity(ec==expParams.eccentricities)./10.^5);
        end
        
        xUnits              = expParams.contrastLevels; % For now use eccentricities as labels, but we could plot it against cone density
        
        
    case 'defocus'
        
        for df = expParams.defocusLevels
            
            % compute defocus
            pupilRadiusMM = 1.5; % mm
            M(df==expParams.defocusLevels) = 4*pi*sqrt(3) * df / (pi* pupilRadiusMM^2); % convert to diopters
            labels{df==expParams.defocusLevels} = sprintf('%2.2f Diopters of Defocus',M(df==expParams.defocusLevels));
        end
        
        colors              = copper(length(expParams.defocusLevels));
        xUnits              = expParams.contrastLevels;
        
end

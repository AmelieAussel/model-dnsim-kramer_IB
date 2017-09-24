

function varargout = dsPlot2_PPStim (data,varargin)

    % get rid of any "all" inputs
    v2 = varargin;
    inds = cellfun(@ischar,v2);
    v2(inds) = cellfun(@(s) strrep(s,'all',':'),v2(inds),'UniformOutput',0);

    options=dsCheckOptions(v2,{...
      'population',[],[],...          % [beg,end] (units must be consistent with dt and equations)  
      'variable',[],[],...          % [beg,end] (units must be consistent with dt and equations)  
      },false);

    
    % Isolates the PPStim pulse train information
    xp = dsAll2mdd(data);
    
    ind = xp.findaxis('variables');
    varvals = xp.exportAxisVals;
    varvals = varvals{ind};
    if any(strcmp(varvals,'iPeriodicPulsesiSYNNested_s')) && any(strcmp(varvals,'iPoissonNested_S3'))    % If both periodic pulses are present...
        % ...then
        xpp1 = xp.axisSubset('variables','iPoissonNested_S3');
        xpp2 = xp.axisSubset('variables','iPeriodicPulsesiSYNNested_s');
        
        dat1=xpp1.exportData;
        dat2=xpp2.exportData;
        
        for i = 1:numel(dat1)
            if ~isempty(dat2{i})        % If data2 isn't empty, import into dat1, overwriting if necessary.
                dat1{i} = dat2{i};
            end
        end
        xpp1.data = dat1;
        xpp = xpp1;
        clear xpp1 xpp2
    elseif  any(strcmp(varvals,'iPeriodicPulsesiSYNNested_s')) && ~any(strcmp(varvals,'iPoissonNested_S3')) 
        xpp = xp.axisSubset('variables','iPeriodicPulsesiSYNNested_s');
    elseif  ~any(strcmp(varvals,'iPeriodicPulsesiSYNNested_s')) && any(strcmp(varvals,'iPoissonNested_S3')) 
        xpp = xp.axisSubset('variables','iPoissonNested_S3');
    else
        error('Periodic pulse variable not found');
    end
    
    xpp = xpp.squeezeRegexp('variables');
    
    if ~isempty(options.population)
        xpp = xpp.axisSubset('population',options.population);
    end

    % Call dsPlot2 supplying this custom function handle.
    varargout = cell(1,nargout);
    [varargout{1:nargout}] = dsPlot2(data,varargin{:},'subplot_handle',@(xp,op) xp_subplot_grid_PPStim(xp,op,xpp));

end
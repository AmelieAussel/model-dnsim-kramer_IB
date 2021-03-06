function [data, name, sim_spec] = kramer_IB_function_mode(sim_struct)

if nargin < 1; sim_struct = []; end
if isempty(sim_struct); sim_struct = struct; end

Today = datestr(datenum(date),'yy-mm-dd');
% mkdir(Today);

savepath = fullfile('Figs_Ben', Today);
mkdir(savepath);

Now = clock;
name = sprintf('kramer_IB_%g_%g_%.4g', Now(4), Now(5), Now(6));

function_mode = 1;

kramer_IB

unpack_sim_struct
% vars_pull(sim_struct);

include_kramer_IB_populations;

include_kramer_IB_synapses;

save(fullfile(savepath, [name, '_sim_spec.mat']), 'sim_spec', 'sim_struct');

if cluster_flag
    
    data=SimulateModel(sim_spec,'tspan',tspan,'dt',dt,'downsample_factor',dsfact,'solver',solver,'coder',0,...
        'random_seed',random_seed,'vary',vary,'verbose_flag',1,'cluster_flag',1,'overwrite_flag',1,...
        'save_data_flag',1,'qsub_mode','loop','study_dir',name);
    
    return

else
    
    data=SimulateModel(sim_spec,'tspan',tspan,'dt',dt,'downsample_factor',dsfact,'solver',solver,'coder',0,...
        'random_seed',random_seed,'vary',vary,'verbose_flag',verbose_flag,'parallel_flag',parallel_flag,...
        'compile_flag',compile_flag);

end

close('all')

PlotData(data)

figHandles = findobj('Type', 'Figure');

for f = 1:length(figHandles)

    save_as_pdf(figHandles(f), fullfile(savepath, [name, '_', num2str(f)]))
    
end

end
 % demo use script

suite2p_exper_dir = ['/Volumes/van-hooser-lab/Users/Diane/For_Steve/SCN1-722'];

target_directory = ['/Users/vanhoosr/Desktop/2722-05-05'];


directory_mapping{1}{1} = 't00001-001';
directory_mapping{1}{2} = {'t00001-001'};
directory_mapping{2}{1} = 't00002-001';
directory_mapping{2}{2} = {'t00002-001'};
directory_mapping{3}{1} = 't00003-001';
directory_mapping{3}{2} = {'t00003-001'};
directory_mapping{4}{1} = 't00004-6-7';
directory_mapping{4}{2} = {'t00004-001','t00006-001','t00007-001'};

channel_mapping = [ 0 2];

do_it = 0; % do we actually do it?

suite2ptifs2prairieview(suite2p_exper_dir,target_directory,directory_mapping,channel_mapping,do_it)



suite2p_exper_dir = ['/Volumes/van-hooser-lab/Users/Diane/For_Steve/SCN1-723'];

target_directory = ['/Users/vanhoosr/Desktop/2723-05-05'];


directory_mapping{1}{1} = 't00001-001';
directory_mapping{1}{2} = {'t00001-001'};
directory_mapping{2}{1} = 't00002-001';
directory_mapping{2}{2} = {'t00002-001'};
directory_mapping{3}{1} = 't00004-001';
directory_mapping{3}{2} = {'t00004-001'};
directory_mapping{4}{1} = 't00005-6-7';
directory_mapping{4}{2} = {'t00005-001','t00006-001','t00007-001'};

channel_mapping = [ 0 2];

do_it = 0; % do we actually do it?

suite2ptifs2prairieview(suite2p_exper_dir,target_directory,directory_mapping,channel_mapping,do_it)

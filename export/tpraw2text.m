function tpraw2text(rawfilename);

% TPRAW2TEXT - Convert a 2-photon raw .mat file to text
%
%  TPRAW2TEXT(RAWFILENAME)
%
%  Converts output from a TwoPhoton raw .mat file to text.
%
%  2 types of files are generated:
%
%   The first is a header file named [RAWFILENAME 'hd.txt'] that has
%   the names of the cells that were analyzed.
%   
%   The second is an Tx2 matrix; the first column is the time of each
%   fluorescence measurement, and the next column contains the fluorescent
%   measurement.  The names of these files are
%   [STACKNAME_cell_####_ref_REFDIR.txt].
%
%   For some cells, there may no measurements (if the cell drifted out of
%   the field of view, or if the cell was not scanned in a particular
%   line scan), in which case the text file will be blank.
%  

[pathstr,filename,ext] = fileparts(rawfilename);

underscores = find(filename=='_');

sitename = filename(1:underscores(1));

if exist(fullfile(pathstr,[filename ext])),
	g = load([rawfilename]);


	% write header file
	fname_header = [pathstr filename 'hd.txt'];
	f_header = fopen(fname_header,'wt');
	
	for i=1:length(g.listofcellnames),
		fprintf(f_header, '%s\n', g.listofcellnames{i});
	end;
	fclose(f_header);

	for i=1:length(g.listofcellnames),
		[cellnum] = sscanf(g.listofcellnames{i},'cell %d'); % read the cell string
		refstr_start = findstr(g.listofcellnames{i},'ref');
		refstr = g.listofcellnames{i}(refstr_start+4:end);
		
		fname_datafile= [pathstr sitename 'cell_' sprintf('%0.4d',cellnum) '_' refstr '.txt'];
		f_data = fopen(fname_datafile,'wt');
		for j=1:length(g.t{i}),
			fprintf(f_data,['%f %f\n'],g.t{i}(j),g.data{i}(j));
		end;
		fclose(f_data);
	end;
else,
	error(['Could not find the file ' rawfilename '.']);
end;

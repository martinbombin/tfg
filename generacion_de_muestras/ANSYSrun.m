clear; clc; close all;

%% AnsysRoute='"E:\Software\ANSYS Inc\ANSYS Student\v192\ansys\bin\winx64\ANSYS192.exe"';
AnsysRoute='"C:\Program Files\ANSYS Inc\ANSYS Student\v202\ANSYS\bin\winx64\ANSYS202.exe"';
CurrentRoute=cd;
FilesRoute=[CurrentRoute '\ansysFiles'];
job_name='test';

delete([FilesRoute '\file.lock']) 
 
%% Simulation in ANSYS
ROWS = 24;
COLS = 32; 

cd(FilesRoute);

newFileName = 'temp.log';
n = 1;
shapes = get_shapes();

for f = 1:6
    shape = shapes(:,:,f);
    fileName= strcat('..\logs\p',string(f),'.log');
    for m = -20:20
        for z = -20:20
            %FX = 200 * rand;
            %FX = FX - 100;
            %FY = 200 * rand;
            %FY = FY - 100;
            delete('von.txt');
            delete('nodes.txt');
            delete('elements.txt');
            
            FX = z*5;
            FY = m*5;

            func_replace_string(fileName, newFileName, 'FX = 0', strcat('FX = ',string(FX)));
            if f == 1 || f ==2
                func_replace_string(newFileName, newFileName, 'FY = 0', strcat('FY = ',string(FY/24)));
            end
            if f == 3 || f == 4
                func_replace_string(newFileName, newFileName, 'FY = 0', strcat('FY = ',string(FY/12)))
            end
            if f == 5 || f == 6
                func_replace_string(newFileName, newFileName, 'FY = 0', strcat('FY = ',string(FY/13)))
            end
            
            callstring=[AnsysRoute,' -b -s noread -dir "',FilesRoute,'" -j ',job_name,...
            ', -i ',newFileName,' -o "Salida.dat" '];

            [SystemError, ~] = system(['SET KMP_STACKSIZE=4096k &',callstring]);

            von = importdata('von.txt');            
            nodes = importdata('nodes.txt');
            elements = importdata('elements.txt');
            
            vonm = zeros(ROWS, COLS);
            desp = 0.000031250;
            
            mshape = zeros(ROWS, COLS);
            for i = 1:ROWS/2
                mshape(i, :) = shape(ROWS+1-i, :);
                mshape(ROWS+1-i, :) = shape(i, :);
            end 
            
            for i = 1:ROWS
                for j = 1:COLS
                    if mshape(i, j) == 1
                        indnod1 = find((abs(nodes(:,1) - (j-1) * desp) <= desp/2) & abs(nodes(:,2) - (i-1) * desp) <= desp/2);
                        indnod2 = find((abs(nodes(:,1) -  j    * desp) <= desp/2) & abs(nodes(:,2) - (i-1) * desp) <= desp/2);
                        indnod3 = find((abs(nodes(:,1) - (j-1) * desp) <= desp/2) & abs(nodes(:,2) -  i    * desp) <= desp/2);
                        indnod4 = find((abs(nodes(:,1) -  j    * desp) <= desp/2) & abs(nodes(:,2) -  i    * desp) <= desp/2);
                        ind = find(...
                                (elements(:,1) == indnod1 | elements(:,1) == indnod2 | elements(:,1) == indnod3 | elements(:,1) == indnod4) &...
                                (elements(:,2) == indnod1 | elements(:,2) == indnod2 | elements(:,2) == indnod3 | elements(:,2) == indnod4) &...
                                (elements(:,3) == indnod1 | elements(:,3) == indnod2 | elements(:,3) == indnod3 | elements(:,3) == indnod4) &...
                                (elements(:,4) == indnod1 | elements(:,4) == indnod2 | elements(:,4) == indnod3 | elements(:,4) == indnod4)...
                              );
                        vonm(ROWS + 1 - i, j) = von(ind)/1000;
                    end
                end
            end
          
            f_x = zeros(ROWS, COLS);
            f_y = zeros(ROWS, COLS);
            s_x = zeros(ROWS, COLS);
            s_y = zeros(ROWS, COLS);

            for i = 1:ROWS
                f_x(i, COLS) = shape(i,COLS)*FX;
                f_y(i, COLS) = shape(i, COLS)*FY;
                s_x(i,1) = -shape(i,1);
                s_y(i,1) = -shape(i,1);
            end

            res = cat(3,shape, f_x, f_y, s_x, s_y, vonm);
            newTestName = strcat('..\testData\image', string(n), '.mat');
            save(newTestName,'res');
            n = n + 1

        end
    end
end

delete('von.txt');
delete('nodes.txt');
delete('elements.txt');

cd('..');

function [] = func_replace_string(InputFile, OutputFile, SearchString, ReplaceString)
    %%change data [e.g. initial conditions] in model file
    % InputFile - string
    % OutputFile - string
    % SearchString - string
    % ReplaceString - string
    % read whole model file data into cell array
    fid = fopen(InputFile);
    data = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
    fclose(fid);
    % modify the cell array
    % find the position where changes need to be applied and insert new data
    for I = 1:length(data{1})
        tf = strcmp(data{1}{I}, SearchString); % search for this string in the array
        if tf == 1
            data{1}{I} = ReplaceString; % replace with this string
        end
    end
    % write the modified cell array into the text file
    fid = fopen(OutputFile, 'w');
    for I = 1:length(data{1})
        fprintf(fid, '%s\n', char(data{1}{I}));
    end
    fclose(fid);
end

function shapes = get_shapes()

    ROWS = 24;
    COLS = 32; 

    fig1 = ones(ROWS, COLS);

    fig2 = ones(ROWS, COLS);
    fig2(9, 15:18) = 0;
    fig2(10, 12:21) = 0;
    fig2(11, 10:23) = 0;
    fig2(12:13, 9:24) = 0;
    fig2(16, 15:18) = 0;
    fig2(15, 12:21) = 0;
    fig2(14, 10:23) = 0;

    fig3 = ones(ROWS, COLS);
    fig3(1, 3:COLS) = 0;
    fig3(2, 8:COLS) = 0;
    fig3(3, 13:COLS) = 0;
    fig3(4, 18:COLS) = 0;
    fig3(5, 23:COLS) = 0;
    fig3(6, 28:COLS) = 0;
    fig3(ROWS, 3:COLS) = 0;
    fig3(ROWS-1, 8:COLS) = 0;
    fig3(ROWS-2, 13:COLS) = 0;
    fig3(ROWS-3, 18:COLS) = 0;
    fig3(ROWS-4, 23:COLS) = 0;
    fig3(ROWS-5, 28:COLS) = 0;

    fig4 = repmat(fig3, 1);
    fig4(10, 15:18) = 0;
    fig4(11, 13:20) = 0;
    fig4(12:13, 11:22) = 0;
    fig4(15, 15:18) = 0;
    fig4(14, 13:20) = 0;

    fig5 = ones(ROWS, COLS);
    fig5(1, :) = 0;
    fig5(1, 2) = 1;
    fig5(2, 12:COLS) = 0;
    fig5(3, 15:COLS) = 0;
    fig5(4, 18:COLS) = 0;
    fig5(5, 21:COLS) = 0;
    fig5(6, 23:COLS) = 0;
    fig5(7, 25:COLS) = 0;
    fig5(8, 27:COLS) = 0;
    fig5(9, 28:COLS) = 0;
    fig5(10, 30:COLS) = 0;
    fig5(11, 31:COLS) = 0;
    
    fig6 = repmat(fig5, 1);
    fig6(10, 9:15) = 0;
    fig6(11:16, 8:16) = 0;
    fig6(17, 9:15) = 0;

    shapes = cat(3, fig1, fig2, fig3, fig4, fig5, fig6);
    
end
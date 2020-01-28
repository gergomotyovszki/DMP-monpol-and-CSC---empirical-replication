classdef preparser < userdataobj
% preparser  [Not a public class] IRIS preparser.
%
% Backend IRIS class.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

    properties
        FName = '';
        Code = '';
        Labels = fragileobj();
        Assign = struct();
        Subs = struct();
    end
        
    
    methods
        function This = preparser(varargin)
            % preparser  [Not a public function] IRIS preparser.
            %
            % Backend IRIS function.
            % No help provided.
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2015 IRIS Solutions Team.
            
            % p = preparser(inpFile,inpCode,Opt)
            % p = preparser(inpFile,inpCode,...)
            
            if nargin == 0
                return
            end

            if isa(varargin{1},'preparser')
                This = varargin{1};
                return
            end
            
            inpFiles = varargin{1};
            inpCode = varargin{2};
            varargin(1:2) = [];
            [opt,~] = passvalopt('preparser.preparser',varargin{:});
            if ~isempty(inpFiles)
                % Read and combine input files.
                [inpCode,fileStr] = preparser.readfile(inpFiles);
            else
                % Use and combine input code directly typed in.
                if iscellstr(inpCode)
                    inpCode = sprintf('%s\n',inpCode{:});
                end
                fileStr = '';
            end
            This.FName = fileStr;
            This.Assign = opt.assign;
            % Run preparser.
            [This.Code,This.Labels,This.Export,This.Subs,This.Comment] = ...
                preparser.parse(inpCode,fileStr, ...
                opt.assign,This.Labels,{},'',opt);
            % Create a clone of the preparsed code.
            if ~isempty(opt.clone)
                This.Code = preparser.myclone(This.Code,opt.clone);
            end
            % Save the pre-parsed file if requested by the user.
            if ~isempty(opt.saveas)
                saveas(This,opt.saveas);
            end
        end
        
        
        function disp(This)
            mosw.fprintf( ...
                '\tpreparser object <a href="matlab:edit %s">%s</a>\n', ...
                This.FName,This.FName);
            disp@userdataobj(This);
            disp(' ');
        end
    end
    
    
    methods
        varargout = saveas(varargin)
    end
    
    
    methods (Static,Hidden)
        varargout = mychkclonestring(varargin)
        varargout = myclone(varargin)
        varargout = alt2str(varargin)
        varargout = eval(varargin)
        varargout = grabcommentblk(varargin)
        varargout = labeledexpr(varargin)
        varargout = lincomb2vec(varargin)
        varargout = controls(varargin)
        varargout = pseudofunc(varargin)
        varargout = pseudosubs(varargin)
        varargout = parse(varargin)
        varargout = readfile(varargin)
        varargout = removecomments(varargin)
        varargout = substitute(varargin)
    end
end

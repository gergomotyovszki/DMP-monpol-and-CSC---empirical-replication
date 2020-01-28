classdef rpteq < getsetobj & userdataobj
    % rpteq  Reporting Equations (rpteq Objects).
    %
    % Reporting equations (rpteq) objects are systems of equations evaluated
    % successively (i.e. not simultaneously) equation by equation, period by
    % period.
    %
    % There are three basic ways to create
    % reporting equations objects: 
    % 
    % * in the [`!reporting_equations`](modellang/reportingequations)
    % section of a model file;
    %
    % * in a separate reporting equations file;
    %
    % * on the fly within an m-file or in the command window.
    %
    % Rpteq methods:
    %
    % Constructor
    % ============
    %
    % * [`rpteq`](rpteq/rpteq) - New reporting equations (rpteq) object.
    %
    % Evaluating reporting equations
    % ===============================
    %
    % * [`run`](rpteq/run) - Evaluate reporting equations (rpteq) object.
    %
    % Evaluating reporting equations from within model object
    % ========================================================
    %
    % * [`reporting`](model/reporting) - Evaluate reporting equations from within model object.
    %
    % Getting on-line help on rpteq functions
    % ========================================
    %
    %     help rpteq
    %     help rpteq/function_name
    %
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2015 IRIS Solutions Team.
    
    properties
        FName = '';
        NameLhs = { };
        NameRhs = { };
        EqtnRhs = { };
        NaN = [ ];
        UsrEqtn = { };
        Label = { };
        MaxSh = 0;
        MinSh = 0;
    end
    
    
    methods
        function This = rpteq(varargin)
            % rpteq  New reporting equations (rpteq) object.
            %
            %
            % Syntax
            % =======
            %
            %     Q = rpteq(FName)
            %     Q = rpteq(Eqtn)
            %
            %
            % Input arguments
            % ================
            %
            % * `FName` [ char | cellstr ] - File name or cellstr array of
            % file names, each a plain text file with reporting equations;
            % multiple input files will be combined together.
            %
            % * `Eqtn` [ char | cellstr ] - Equation or cellstr array of
            % equations.
            %
            % Output arguments
            % =================
            %
            % * `Q` [ rpteq ] - New reporting equations object.
            %
            % Description
            % ============
            %
            % Reporting equations must be written in the following form:
            %
            %     `LhsName = RhsExpr;`
            %     `"Label" LhsName = RhsExpr;`
            %
            % where
            %
            % * `LhsName` is the name of a left-hand-side variable (with no
            % lag or lead);
            %
            % * `RhsExpr` is an expression on the right-hand side that will
            % be evaluated period by period, and assigned to the
            % left-hand-side variable, `LhsName`.
            %
            % * `"Label"` is an optional label that will be used to create
            % a comment in the output time series for the respective
            % left-hand-side variable.
            %
            % * the equation must end with a semicolon.
            %
            % Example
            % ========
            %
            %     q = rpteq({ ...
            %         'a = c * a{-1}^0.8 * b{-1}^0.2;', ...
            %         'b = sqrt(b{-1});', ...
            %         })
            %
            %     q =
            %         rpteq object
            %         number of equations: [2]
            %         comment: ''
            %         user data: empty
            %         export files: [0]
            %
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2015 IRIS Solutions Team.
            
            %--------------------------------------------------------------            
            
            if isempty(varargin)
                return
            end
            
            if length(varargin) == 1 && isa(varargin{1},'rpteq')
                This = varargin{1};
                return
            end
            
            if length(varargin) >= 1
                if isstruct(varargin{1})
                    % Preparsed code from model object.
                    s = varargin{1};
                    This.FName = varargin{2};
                elseif ischar(varargin{1}) || iscellstr(varargin{1})
                    inp = varargin{1};
                    varargin(1) = [];
                    opt = passvalopt('rpteq.rpteq',varargin{:});
                    % Tell apart equations from file names.
                    if ischar(inp)
                        inp = { inp };
                    end
                    ixFName = cellfun(@isempty,strfind(inp,'='));
                    if all(ixFName)
                        % Input is file name or cellstr of file names.
                        pre = preparser(inp,[],opt);
                    elseif all(~ixFName)
                        % Input is equation or cellstr of equations.
                        pre = preparser([],inp,opt);
                    else
                        utils.error('rpteq:rpteq', ...
                            ['Input to rpteq( ) must be either file name(s), ', ...
                            'or equation(s), but not combination of both.']);
                    end
                    This.FName = pre.FName;
                    This.Export = pre.Export;
                    export(This);
                    % Supply the keyword `!reporting_equations` if missing from the file.
                    if isempty(strfind(pre.Code,'!reporting_equations'))
                        br = sprintf('\n');
                        pre.Code = [ ...
                            '!reporting_equations',br, ...
                            pre.Code, ...
                            ];
                    end
                    % Run theparser on preparsed code.
                    the = theparser('rpteq',pre);
                    s = parse(the);
                end
                
                % Run rpteq parser.
                This = myparse(This,s);
                return
            end
        end
    end
    
    
    methods
        varargout = run(varargin)
    end
    
    
    methods (Hidden)
        varargout = disp(varargin)
        varargout = specget(varargin);
    end
    
    
    methods (Access=protected,Hidden)
        varargout = myparse(varargin)
    end
end

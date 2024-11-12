function [d] = retrieveData(userID)

% headerField = matlab.net.http.field.ContentTypeField('application/x-www-form-urlencoded');
% url = 'http://79.136.70.172:7403/retrieveOp.php';
url = 'http://om2.it.liu.se:8080/retrieveOp.php';

un = 'jorbl45';
pw = 'Q8rkS97.jEj'; //Check password

% input = struct('user',un,'password',pw, 'userID', 1);
% inputParameters = struct('parameters', input);
% aTest = jsonencode(inputParameters);
% options = matlab.net.http.HTTPOptions();
% method = matlab.net.http.RequestMethod.POST;
% request = matlab.net.http.RequestMessage(method,headerField, aTest);
% show(request)
% resp = send(request,url, options);


% options = weboptions('RequestMethod', 'post', 'ArrayFormat','json');
% options = weboptions('MediaType','application/json','ContentType','json');
% data = webwrite(url, input, options);

options = weboptions('RequestMethod','post', 'ArrayFormat','json', 'Timeout', 30);
data = webread(url, 'user',un,'password',pw, 'userID', userID, options);
str = native2unicode(data, 'UTF-8');
data = convertCharsToStrings(str);
d = split(data, ' ');
times = d(3:2:end-1);
input = d(4:2:end-1);

d = cell(1E5,1); % data questions and answers

i = 1;
for j = 1:length(times)
  tInt = str2num(['uint64(',times{j},')']);
  str = input{j};
  if (length(str) >= 3) % Question
    
    ind = regexp(str,'[\+\-\*/]');
    d{i}.qt = tInt;
    d{i}.x = str2num(['uint8(',str(1:ind-1),')']);
    d{i}.op = str(ind);
    d{i}.y = str2num(['uint8(',str(ind+1:end),')']);
    if (d{i}.op == '+')
      d{i}.z = d{i}.x + d{i}.y;
    elseif (d{i}.op == '-')
      d{i}.z = d{i}.x - d{i}.y;
    elseif (d{i}.op == '*')
      d{i}.z = d{i}.x * d{i}.y;
    elseif (d{i}.op == '/')
      d{i}.z = d{i}.x / d{i}.y;
    else
      errror('Unknown operation');
    end
    at = [];
    a = [];
    as = []; % Answer string
  elseif (length(str) == 1) % Key pressed
    k = str(1);
    at = [at ; tInt];
    a = [a ; k];
    if (k == 'C')
      as = [];
    elseif (k == '=')
      d{i}.z_ = str2num(['uint8(',as,')']);
      d{i}.z_t = tInt;
      d{i}.at = at;
      d{i}.a = a;
      i = i+1;
    else
      as = [as k];
    end
  else
    error('Incorrect line');
  end
%   tDT = datetime(tInt,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS');
%   t = datenum(tDT);
end
d = d(1:i-1);

n = length(d);
tVec = zeros(n, 6);
t = zeros(n,1);
for i=1:n
  a = datetime(1970,1,1,0,0,0,d{i}.qt);
  tVec(i,:) = datevec(a);
  t(i) = datenum(tVec(i,:));
end

plot(t, 1:n);
datetick('x', 'mmm');
fprintf('%d frgor besvarade frn %s till %s\n', n, datestr(t(1)), datestr(t(end)));
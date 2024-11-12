function [d] = retrieveUsers()

% headerField = matlab.net.http.field.ContentTypeField('application/x-www-form-urlencoded');
% url = 'http://79.136.70.172:7403/retrieveOp.php';
url = 'http://om2.it.liu.se:8080/retrieveUserNames.php';

un = 'jorbl45';
pw = 'Q8rkS97.jEj';

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

options = weboptions('RequestMethod','post', 'ArrayFormat','json');
data = webread(url, 'user',un,'password',pw, options)
str = native2unicode(data, 'UTF-8');
data = convertCharsToStrings(str);
data = data{1}(8:end);
d = split(data, '\\');
n = floor(length(d)/19);
d = reshape(d(1:n*19), 19,n)';

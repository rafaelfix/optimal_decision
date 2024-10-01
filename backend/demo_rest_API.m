function [d] = demo_rest_API()
    url = "http://localhost:8088/";
    
    un = 'jorbl45';
    pw = 'Q8rkS97.jEj';

    users_path = "csv/get_users";
    user_tasks_path = "csv/get_user_tasks";
    user_keypresses_path = "csv/get_user_keypresses";
    user_sessions_path = "csv/get_user_sessions";
    android = "csv/get_user_android_devices";
    ios = "csv/get_user_ios_devices";
    synchronizations = "csv/get_user_synchronizations";
    accounts = "csv/get_user_management_accounts";
    

    options = weboptions('RequestMethod', 'post');
    data = webread(url+users_path, 'username',un,'password',pw, options)
    
    data_tasks = webread(url+user_tasks_path, 'username',un,'password',pw, 'user_pks', "5,6", options)
    
    data_sessions = webread(url+user_sessions_path, 'username',un,'password',pw, 'user_pks', "5", options)

    data_keypress = webread(url+user_keypresses_path, 'username',un,'password',pw, 'user_pks', "5", options)

    data_android = webread(url+android, 'username',un,'password',pw, 'user_pks', "5", options)

    data_ios = webread(url+ios, 'username',un,'password',pw, 'user_pks', "5", options)

    data_synchronizations = webread(url+synchronizations, 'username',un,'password',pw, 'account_pks', "2,8,9,10", options)

    data_users_in_synchronization = webread(url+users_path, 'username',un,'password',pw, 'synchronization_pk', "1", options)

    data_accounts = webread(url+accounts, 'username',un,'password',pw, options)

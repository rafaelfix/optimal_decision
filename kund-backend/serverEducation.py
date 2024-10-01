#!/usr/bin/env python
# Based on: https://stackoverflow.com/questions/41429172/python-basehttprequesthandler-respond-with-json
# Reflects the requests with dummy responses from HTTP methods GET, POST, PUT, and DELETE

import json
import sqlite3
import os.path
from http.server import HTTPServer, BaseHTTPRequestHandler
import ssl
import urllib.parse
from optparse import OptionParser

def createTableUser(dbName):
    conn = sqlite3.connect(dbName)
    c = conn.cursor()
    c.execute('''CREATE TABLE USER
              ([userID] INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
               [deviceID] TEXT,
               [name] TEXT,
               [firstUsage] INTEGER,
               [board] TEXT,
               [brand] TEXT,
               [device] TEXT,
               [hardware] TEXT,
               [host] TEXT,
               [id] TEXT,
               [manufacturer] TEXT,
               [model] TEXT,
               [product] TEXT,
               [tags] TEXT,
               [type] TEXT,
               [user] TEXT,
               [radioVersion] TEXT,
               [vRelease] TEXT,
               [vIncremental] TEXT,
               [vSdkInt] INTEGER)''')
    conn.commit()

def createTableQA(dbName): # Questions and Answers
    conn = sqlite3.connect(dbName)
    c = conn.cursor()
    c.execute('''CREATE TABLE QA
              ([userID] INTEGER NOT NULL,
               [time] INTEGER,
               [value] TEXT)''')
    conn.commit()

def storeDataUser(dbName, txtList):
    data = [None]*19
    print("Number of arguments in addUser:", len(txtList))
    if (len(txtList) != 19):
        return -1

    for e in txtList:
        print(e)
        pair = e.split("=") 
        if (pair[0]=="deviceID"):
            data[0] = pair[1]
        elif (pair[0]=="name"):
            data[1] = pair[1]
        elif (pair[0]=="firstUsage"):
            data[2] = pair[1]
        elif (pair[0]=="board"):
            data[3] = pair[1]
        elif (pair[0]=="brand"):
            data[4] = pair[1]
        elif (pair[0]=="device"):
            data[5] = pair[1]
        elif (pair[0]=="hardware"):
            data[6] = pair[1]
        elif (pair[0]=="host"):
            data[7] = pair[1]
        elif (pair[0]=="id"):
            data[8] = pair[1]
        elif (pair[0]=="manufacturer"):
            data[9] = pair[1]
        elif (pair[0]=="model"):
            data[10] = pair[1]
        elif (pair[0]=="product"):
            data[11] = pair[1]
        elif (pair[0]=="tags"):
            data[12] = pair[1]
        elif (pair[0]=="type"):
            data[13] = pair[1]
        elif (pair[0]=="user"):
            data[14] = pair[1]
        elif (pair[0]=="radioVersion"):
            data[15] = pair[1]
        elif (pair[0]=="vRelease"):
            data[16] = pair[1]
        elif (pair[0]=="vIncremental"):
            data[17] = pair[1]
        elif (pair[0]=="vSdkInt"):
            data[18] = pair[1]
        else:
            return -2

    conn = sqlite3.connect(dbName)
    c = conn.cursor()

    insertQuery = "INSERT INTO USER (deviceID, name, firstUsage, board, brand, device, hardware, host, id, manufacturer, model, product, tags, type, user, radioVersion, vRelease, vIncremental, vSdkInt) VALUES ('" + data[0] + "', '" + data[1] + "', " + data[2] + ", '" + data[3] + "', '" + data[4] + "', '" + data[5] + "', '" + data[6] + "', '" + data[7] + "', '" + data[8] + "', '" + data[9] + "', '" + data[10] + "', '" + data[11] + "', '" + data[12] + "', '" + data[13] + "', '" + data[14] + "', '" + data[15] + "', '" + data[16] + "', '" + data[17] + "', " + data[18] + ")"
    print(insertQuery)
    c.execute(insertQuery)
    userID = c.lastrowid
    print("lastRow =", userID)
    conn.commit()
    return userID

def storeDataQA(dbName, txtList):
    if (len(txtList) == 3): # This is the old version with arguments (userID, times, values)
        return storeDataQAv1(dbName, txtList)
    elif (len(txtList) == 5): # This is the new version with arguments (userID, version, nApp, times, values)
        return storeDataQAv2(dbName, txtList)
    else:
        return -1

def storeDataQAv1(dbName, txtList):

    pair = txtList[0].split("=")
    if (pair[0]!="userID"):
        return -2

    userID = pair[1]

    pair = txtList[1].split("=")
    times = pair[1].split(" ")
    txtValues = txtList[2]
    iFirst = txtValues.find("=")
    txtValues = txtValues[(iFirst+1):len(txtValues)]
    print("txtValues = ", txtValues)
    values = txtValues.split(" ")
    print("Values = ", values)
    print("Length times: ", len(times))
    print("Length values: ", len(values))
    if (len(times) != len(values)):
        return -3

    conn = sqlite3.connect(dbName)
    c = conn.cursor()

    data = [None]*len(times)
    for i in range(len(times)):
        data[i] = (userID, times[i], values[i])
    c.executemany('INSERT INTO QA VALUES(?,?,?);',data);
    print("Insert: ", data)

    #insertQuery = "BEGIN TRANSACTION;\n"
    #for i in range(len(times)):
    #    insertQuery = insertQuery + "INSERT INTO QA (userID, time, value) VALUES (" + userID + ", " + times[i] + ", '" + values[i] + "');\n"    
    #insertQuery = insertQuery + "COMMIT;\n"
    #print(insertQuery)
    #c.execute(insertQuery)


    nDb = 0
    print("nDb =", nDb)
    conn.commit()
    return nDb

def storeDataQAv2(dbName, txtList):

    pair = txtList[0].split("=")
    if (pair[0]!="userID"):
        return -2
    userID = pair[1]

    pair = txtList[1].split("=")
    if (pair[0]!="version"):
        return -3
    version = int(pair[1])

    pair = txtList[2].split("=")
    if (pair[0]!="nApp"):
        return -4
    nApp = int(pair[1])

    pair = txtList[3].split("=")
    times = pair[1].split(" ")
    txtValues = txtList[4]
    iFirst = txtValues.find("=")
    txtValues = txtValues[(iFirst+1):len(txtValues)]
    print("txtValues = ", txtValues)
    values = txtValues.split(" ")
    print("Values = ", values)
    print("Length times: ", len(times))
    print("Length values: ", len(values))
    if (len(times) != len(values)):
        return -3

    conn = sqlite3.connect(dbName)
    c = conn.cursor()

    countQuery = "SELECT COUNT(*) FROM QA WHERE userID = " + userID + ";"
    print(countQuery)
    c.execute(countQuery)
    nDbResult = c.fetchone();
    print("nDbResult = ", nDbResult)
    nDbOld = nDbResult[0]
    print("nDb before storing = ", nDbOld)

    data = [None]*len(times)
    for i in range(len(times)):
        data[i] = (userID, times[i], values[i])
    c.executemany('INSERT INTO QA VALUES(?,?,?);',data);
    print("Insert: ", data)

    #insertQuery = "BEGIN TRANSACTION;\n"
    #for i in range(len(times)):
    #    insertQuery = insertQuery + "INSERT INTO QA (userID, time, value) VALUES (" + userID + ", " + times[i] + ", '" + values[i] + "');\n"    
    #insertQuery = insertQuery + "COMMIT;\n"
    #print(insertQuery)
    #c.execute(insertQuery)

    nDb = nDbOld + len(times)
    print("nDb =", nDb)
    if (nDb != nApp):
        print("nDb = ", nDb, ", nApp =", nApp, " => Clearing data for userID =", userID)
        deleteQuery = "DELETE FROM QA WHERE userID = " + userID + ";"
        c.execute(deleteQuery)
        nDb = 0
    conn.commit()
    return nDb

def retrieveUserQA(dbName, txtList):
    if (len(txtList) != 3):
        return -1
    pair = txtList[0].split("=")
    if (pair[1] != "jorbl45"):
        return -2
    pair = txtList[1].split("=")
    if (pair[1] != "Q8rkS97.jEj"):
        return -3
    pair = txtList[2].split("=")
    userID = int(pair[1])
    if (userID < 0):
        return -4

    conn = sqlite3.connect(dbName)
    c = conn.cursor()
    c.execute("SELECT * FROM QA WHERE userID=?", (userID,))
    rows = c.fetchall()
    qa = ""
    for row in rows:
        #print(row)
        qa = qa + str(row[1]) + " " + str(row[2]) + " "
    return qa

def retrieveUserNames(dbName, txtList):
    if (len(txtList) != 2):
        return -1
    pair = txtList[0].split("=")
    if (pair[1] != "jorbl45"):
        return -2
    pair = txtList[1].split("=")
    if (pair[1] != "Q8rkS97.jEj"):
        return -3

    conn = sqlite3.connect(dbName)
    c = conn.cursor()
    c.execute("SELECT * FROM USER")
    rows = c.fetchall()
    u = ""
    for row in rows:
        print(row)
        u = u + str(row[1]) + "\\\\" + str(row[2]) + "\\\\" + str(row[3]) + "\\\\" + str(row[4]) + "\\\\" + str(row[5]) + "\\\\" + str(row[6]) + "\\\\" + str(row[7]) + "\\\\" + str(row[8]) + "\\\\" + str(row[9]) + "\\\\" + str(row[10]) + "\\\\" + str(row[11]) + "\\\\" + str(row[12]) + "\\\\" + str(row[13]) + "\\\\" + str(row[14]) + "\\\\" + str(row[15]) + "\\\\" + str(row[16]) + "\\\\" + str(row[17]) + "\\\\" + str(row[18]) + "\\\\" + str(row[19]) + "\\\\"
    return u

class RequestHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        self.log_message("GET: " + self.path)

        request_path = self.path

        #print("\n----- Request Start ----->\n")
        #print("request_path :", request_path)
        #print("self.headers :", self.headers)
        #print("<----- Request End -----\n")

        #self.send_response(200)
        #self.send_header("Set-Cookie", "foo=bar")
        #self.end_headers()
        #self.wfile.write(bytes(json.dumps({'hello': 'world', 'received': 'ok'}), 'utf-8'))

        return

    def do_POST(self):
        self.log_message("POST: " + self.path)
        request_path = self.path
        print("do_POST request_path :", request_path)
        print(request_path[0:15])

        if (request_path == "/addUser.php" or request_path == "/addValue.php"):
            request_headers = self.headers
            print("headers :", request_headers)
            length = int(self.headers.get('content-length', 0))
            txtData = self.rfile.read(length)
            #print("content 1: ", txtData)
            txtData = txtData.decode('utf-8')
            #print("content 2: ", txtData)
            txtData = urllib.parse.unquote_plus(txtData)
            print("content: ", txtData)
            txtList = txtData.split("&")            
        elif (request_path[0:15] == "/retrieveOp.php"):
            print(request_path)
            pair = request_path.split("?")
            txtData = pair[1]
            print("content: ", txtData)
            txtList = txtData.split("&")
        elif (request_path[0:22] == "/retrieveUserNames.php"):
            print(request_path)
            pair = request_path.split("?")
            txtData = pair[1]
            print("content: ", txtData)
            txtList = txtData.split("&")
        else:
            return

        dbName = 'singleDigit.db'

        if (request_path == "/addUser.php"):
            userID = storeDataUser(dbName, txtList)
            if (userID < 0):
                return

            self.send_response(200)
            self.end_headers()
            returnString = bytes("userID = " + str(userID), 'utf-8')
            self.wfile.write(returnString)
        elif (request_path == "/addValue.php"):
            nDb = storeDataQA(dbName, txtList)
            if (nDb < 0):
                return

            self.send_response(200)
            self.end_headers()
            returnString = bytes("nDb = " + str(nDb), 'utf-8')
            self.wfile.write(returnString)
        elif (request_path[0:15] == "/retrieveOp.php"):
            qa = retrieveUserQA(dbName, txtList)
            returnString = bytes("data = " + qa, 'utf-8')
            #print(returnString)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(returnString)
        elif (request_path[0:22] == "/retrieveUserNames.php"):
            users = retrieveUserNames(dbName, txtList)
            print(users)
            returnString = bytes("data = " + users, 'utf-8')
            #print(returnString)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(returnString)
            

    def do_PUT(self):
        self.log_message("PUT: " + self.path)
        return

    def do_DELETE(self):
        self.log_message("DELETE: " + self.path)
        return

def main():
    dbName = 'singleDigit.db'
    if not os.path.isfile(dbName):
        createTableUser(dbName)
        createTableQA(dbName)

    port = 8080
    print('Listening on localhost:%s' % port)
    server = HTTPServer(('', port), RequestHandler)
    #server.socket = ssl.wrap_socket (server.socket, certfile='/home/jorbl45/certs/optimalmeasurements.it.liu.se.key', server_side=True)
    server.serve_forever()
    server.socket = ssl.wrap_socket(httpd.socket, certfile='/home/jorbl45/certs/cert-optimalmeasurements.it.liu.se.pem',keyfile='/home/jorbl45/certs/optimalmeasurements.it.liu.se.key', server_side=True)

if __name__ == "__main__":
    parser = OptionParser()
    parser.usage = ("Creates an http-server that will echo out any GET or POST parameters, and respond with dummy data\n"
                    "Run:\n\n")
    (options, args) = parser.parse_args()

    main()

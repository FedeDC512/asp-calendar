<%@LANGUAGE = VBScript%>
<!--#include file="ASPMD5/class_md5.asp"-->

<%
Dim conn, rs
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"


Dim objMD5, hashed_password, username, is_admin
Set objMD5 = New MD5
objMD5.Text = Request.Form("password")
hashed_password = objMD5.HEXMD5
username = Request.Form("username")

Dim verify
verify = "SELECT username, is_admin, u_id FROM c_users WHERE username = '" & username & "' AND password = '" & hashed_password & "'"
Set rs = conn.Execute(verify)

If rs.EOF Then

    is_admin = 0
    If Request.Form("is_admin") = "on" then
    is_admin = 1
    End If

    Dim SQL
    SQL = "INSERT INTO c_users (username, password, is_admin) VALUES ('"& username &"', '"& hashed_password &"', '"& is_admin &"')"

    conn.Execute(SQL)

    conn.Close
    Set conn = Nothing

    Response.Write("<script language=""javascript"">alert('The user has been correctly registered! Please log in with your new credentials.'); window.location='index.asp';</script>")
    Response.End

Else
    conn.Close
    Set conn = Nothing

    Response.Write("<script language=""javascript"">alert('This user is already registered!'); window.location='index.asp';</script>")
    Response.End
End If

Response.Redirect "index.asp"

%>
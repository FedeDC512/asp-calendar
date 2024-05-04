<%
' Verifica se la sessione è attiva
If Session.Contents.Count = 0 Then
    Response.Status = "403 Forbidden"
    Response.Write "The session has expired"
    Response.End
Else
    ' Aggiorna il timestamp della sessione per mantenerla attiva
    Session("LastActivity") = Now()
    Response.Write "Session maintained active"
End If
%>
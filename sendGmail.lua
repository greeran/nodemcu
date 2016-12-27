 -- Modifications for GMAIL by Andreas "Andy" Reischle: www.AReResearch.net  
 -- See https://support.google.com/a/answer/176600?hl=de for details on smtp with gmail  
 -- Now that NodeMCU has working SSL support, we can also talk to email services that  
 -- require encryption.   
 -- Caveat: I have not looked into the SSL implementation, but I suspect it is vulnerable  
 -- to man-in-the-middle attacks as the client doesn't check the server's certificate.  
 -- 20160415 ARe  
 --------Original Credits:  
 --------  
 ------- Working Example: https://www.youtube.com/watch?v=CcRbFIJ8aeU  
 ------- @description a basic SMTP email example. You must use an account which can provide unencrypted authenticated access.  
 ------- This example was tested with an AOL and Time Warner email accounts. GMail does not offer unecrypted authenticated access.  
 ------- To obtain your email's SMTP server and port simply Google it e.g. [my email domain] SMTP settings  
 ------- For example for timewarner you'll get to this page http://www.timewarnercable.com/en/support/faqs/faqs-internet/e-mailacco/incoming-outgoing-server-addresses.html  
 ------- To Learn more about SMTP email visit:  
 ------- SMTP Commands Reference - http://www.samlogic.net/articles/smtp-commands-reference.htm  
 ------- See "SMTP transport example" in this page http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol  
 ------- @author Miguel  
 --no longer required because it is part of the crypto module: require("base64")  
 -- The email and password from the account you want to send emails from  
 -- 
 
 local sendGmailClass={}
 
 local MY_EMAIL = "postmaster@sandbox5415a5ae2f9444c68831550eb196ce8b.mailgun.org"  
 local EMAIL_PASSWORD = "QAZWSX12"  
 -- The SMTP server and port of your email provider.  
 -- If you don't know it google [my email provider] SMTP settings  
 local SMTP_SERVER = "smtp.mailgun.org"  
 local SMTP_PORT = "465"--"587"  
 -- The account you want to send email to  
 local mail_to_addr = "greeranjunk@gmail.com"  
 -- These are global variables. Don't change their values  
 -- they will be changed in the functions below  
 local email_subject = "testing"  
 local email_body = "test bosy"  
 local count = 0  
 local smtp_socket = nil -- will be used as socket to email server  
 -- The display() function will be used to print the SMTP server's response  
 function display(sck,response)  
    print("Got a response: ")  
    print(response)  
 end  
 -- The do_next() function is used to send the SMTP commands to the SMTP server in the required sequence.  
 -- I was going to use socket callbacks but the code would not run callbacks after the first 3.  
 function do_next()  
       if(count == 0)then  
         count = count+1  
         local IP_ADDRESS = wifi.sta.getip()  
         print ("Send my IP: " .. IP_ADDRESS)  
         smtp_socket:send("HELO "..IP_ADDRESS.."\r\n")  
       elseif(count==1) then  
         count = count+1  
         smtp_socket:send("AUTH LOGIN\r\n")  
       elseif(count == 2) then  
         count = count + 1  
         smtp_socket:send(crypto.toBase64(MY_EMAIL).."\r\n")  
       elseif(count == 3) then  
         count = count + 1  
         smtp_socket:send(crypto.toBase64(EMAIL_PASSWORD).."\r\n")  
       elseif(count==4) then  
         count = count+1  
         smtp_socket:send("MAIL FROM:<" .. MY_EMAIL .. ">\r\n")  
       elseif(count==5) then  
         count = count+1  
         smtp_socket:send("RCPT TO:<" .. mail_to_addr ..">\r\n")  
       elseif(count==6) then  
         count = count+1  
         smtp_socket:send("DATA\r\n")  
       elseif(count==7) then  
         count = count+1  
         local message = string.gsub(  
         "From: \"".. MY_EMAIL .."\"<"..MY_EMAIL..">\r\n" ..  
         "To: \"".. mail_to_addr .. "\"<".. mail_to_addr..">\r\n"..  
         "Subject: ".. email_subject .. "\r\n\r\n" ..  
         email_body,"\r\n.\r\n","")  
         smtp_socket:send(message.."\r\n.\r\n")  
       elseif(count==8) then  
         count = count+1  
          tmr.stop(0)  
          smtp_socket:send("QUIT\r\n")  
          NotificationFail=true
       else  
         smtp_socket:close()  
       end  
 end  
 -- The connectted() function is executed when the SMTP socket is connected to the SMTP server.  
 -- This function will create a timer to call the do_next function which will send the SMTP commands  
 -- in sequence, one by one, every 5000 seconds.   
 -- You can change the time to be smaller if that works for you, I used 5000ms just because.  
 function connected(sck)  
   print("Connected - Starting Timer")  
   tmr.alarm(0,5000,1,do_next)  
 end  
 -- @name send_email  
 -- @description Will initiated a socket connection to the SMTP server and trigger the connected() function  
 -- @param subject The email's subject  
 -- @param body The email's body  
 function send_email(subject,body)  
    count = 0  
    email_subject = subject  
    email_body = body  
    print ("Open Connection")  
    smtp_socket = net.createConnection(net.TCP,1)  
    smtp_socket:on("connection",connected)  
    smtp_socket:on("receive",display)  
    print("connecting to "..SMTP_SERVER..":"..SMTP_PORT.." ")
    smtp_socket:connect(SMTP_PORT,SMTP_SERVER)  
 end
 
 function sendGmailClass.sendGmailFunc(mail_to,temp,humid)
 -- Send an email  
  if(mail_to == nil)then
    print("no mail to notifiy")
  else
    print ("Sending started..."..mail_to)  
    mail_to_addr=mail_to
    send_email("Tempreture or Humidity Ineterval",
    "Everything is OK\nTempratur ["..temp.."]\nHumitity ["..humid.."]")
  end
 end
 
 function sendGmailClass.sendBadTempFunc(mail_to,temp,humid)
 -- Send an email  
  if(mail_to == nil)then
    print("no mail to notifiy")
  else
    print ("Sending started..."..mail_to)  
    mail_to_addr=mail_to
    send_email("Bad Tempreture or Humidity",
    "There is a problem with the Temprature or Humidity\nTempratur ["..temp.."]\nHumitity ["..humid.."]")  
  end
 end
 
return sendGmailClass;

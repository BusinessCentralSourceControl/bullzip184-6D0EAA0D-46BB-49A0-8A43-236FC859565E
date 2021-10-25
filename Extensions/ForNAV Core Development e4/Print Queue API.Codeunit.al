codeunit 6188511 "Print Queue API"
{
    procedure JobCount(): Integer var r: Record "ForNAV Local Print Queue";
    begin
        exit(r.Count);
    end;
    // [IntegrationEvent(false, false)]
    // procedure OnPrintJobReady(id: Integer);
    // begin
    // end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Print Queue API", 'OnPrintJobReady', '', true, true)]
    // procedure SetJobReady(id: Integer);
    // var
    //     moniker: Codeunit "ForNAV Print Queue Moniker";
    // begin
    //     PrintJobReady := true;
    //     moniker.Increase();
    // end;
    procedure GetJob(serviceName: Text): Text;
    var PrintQueue: Record "ForNAV Local Print Queue";
    CloudPrinterConnection: Record "ForNAV Cloud Printer Conn.";
    Base64Convert: Codeunit "Base64 Convert";
    jobId: Integer;
    localPrinter: Text;
    j: JsonObject;
    retv: Text;
    base64: Text;
    inStr: InStream;
    startTime: DateTime;
    timeSpan: Decimal;
    jobReady: Boolean;
    begin
        // Create a loop that sleeps and waits for a signal from print queue table. 
        PrintQueue.SetRange(Status, PrintQueue.Status::Ready);
        // Poll for job
        startTime:=CurrentDateTime();
        timeSpan:=CurrentDateTime - startTime;
        jobReady:=PrintQueue.FindFirst();
        while((timeSpan < 10000) and (not jobReady))do begin
            Sleep(1000);
            timeSpan:=CurrentDateTime - startTime;
            SelectLatestVersion();
            jobReady:=PrintQueue.FindFirst();
        end;
        // Check if there is a job that belongs to the current service
        if jobReady then begin
            repeat CloudPrinterConnection.SetRange("Cloud Printer", PrintQueue."Cloud Printer Name");
                CloudPrinterConnection.SetFilter(Service, '%1|''''', serviceName);
                CloudPrinterConnection.SetAscending(Service, false);
                if(CloudPrinterConnection.FindFirst())then begin
                    jobId:=PrintQueue.ID;
                    localPrinter:=CloudPrinterConnection."Local Printer";
                end;
            until(PrintQueue.Next() = 0) or (jobId <> 0);
        end;
        jobReady:=jobId <> 0;
        if jobReady then begin
            PrintQueue.SetRange(ID, jobId);
            PrintQueue.LockTable(true);
            if PrintQueue.FindFirst()then begin
                j.Add('ID', PrintQueue.ID);
                j.Add('CloudPrinterName', PrintQueue."Cloud Printer Name");
                j.Add('ReportID', PrintQueue.ReportID);
                j.Add('DocumentName', PrintQueue."Document Name");
                j.Add('Owner', PrintQueue.Owner);
                j.Add('LocalPrinterName', localPrinter);
                j.Add('Company', PrintQueue.Company);
                // Set status to spooling
                PrintQueue.Status:=PrintQueue.Status::Printing;
                PrintQueue."Service":=serviceName;
                PrintQueue.Modify(true);
                Commit(); // Update the table with spooling status and unlock the table while returning the document.
                // Add the document to the result
                PrintQueue.CalcFields(Document);
                PrintQueue.Document.CreateInStream(instr);
                base64:=Base64Convert.ToBase64(InStr);
                j.Add('Document', base64);
            end;
        end;
        j.WriteTo(retv);
        exit(retv);
    end;
    procedure SetStatus(id: Integer;
    status: Text;
    serviceName: Text)var rec: Record "ForNAV Local Print Queue";
    begin
        if rec.Get(id)then begin
            rec.Status:=Enum::"ForNAV Local Print Status".FromInteger("ForNAV Local Print Status".Ordinals.Get("ForNAV Local Print Status".Names.IndexOf(status)));
            rec.Service:=serviceName;
            rec.Modify(true);
        end;
    end;
    procedure DeleteJob(id: Integer)var rec: Record "ForNAV Local Print Queue";
    begin
        if rec.Get(id)then rec.Delete(true);
    end;
    procedure UpdatePrinters(serviceName: Text;
    json: Text)var ServicePrinter: Record "ForNAV Service Printer";
    jObj: JsonObject;
    t: JsonToken;
    a: JsonArray;
    k: Text;
    begin
        // Remove old entries for this service
        ServicePrinter.SetRange(Service, serviceName);
        ServicePrinter.DeleteAll(true);
        a.ReadFrom(json);
        foreach t in a do begin
            // jObj.SelectToken(k, t);
            ServicePrinter.Init();
            ServicePrinter.Service:=serviceName;
            ServicePrinter.LocalPrinter:=t.AsValue().AsText();
            ServicePrinter.Insert(true);
        end;
    end;
}

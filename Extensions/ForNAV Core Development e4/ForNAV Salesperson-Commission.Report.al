Report 6188686 "ForNAV Salesperson-Commission"
{
    Caption = 'Salesperson Commission';
    UsageCategory = ReportsAndAnalysis;
    WordLayout = './Layouts/ForNAV Salesperson-Commission.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(Args;"ForNAV Salesperson-Comm. Args.")
        {
            DataItemTableView = sorting("New Page per Person");
            UseTemporary = true;

            column(ReportForNavId_1000000000;1000000000)
            {
            } // Autogenerated by ForNav - Do not delete
            column(ReportForNav_Args;ReportForNavWriteDataItem('Args', Args))
            {
            }
            trigger OnPreDataItem();
            begin
                Insert;
                ReportForNav.OnPreDataItem('Args', Args);
            end;
        }
        dataitem(SalespersonPurchaser;"Salesperson/Purchaser")
        {
            DataItemTableView = sorting(Code);
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Code";

            column(ReportForNavId_3065;3065)
            {
            } // Autogenerated by ForNav - Do not delete
            column(ReportForNav_SalespersonPurchaser;ReportForNavWriteDataItem('SalespersonPurchaser', SalespersonPurchaser))
            {
            }
            dataitem(CustLedgerEntry;"Cust. Ledger Entry")
            {
                DataItemLink = "Salesperson Code"=FIELD(Code);
                DataItemTableView = sorting("Salesperson Code", "Posting Date")where("Document Type"=filter(Invoice|"Credit Memo"));
                RequestFilterFields = "Posting Date";

                column(ReportForNavId_8503;8503)
                {
                } // Autogenerated by ForNav - Do not delete
                column(ReportForNav_CustLedgerEntry;ReportForNavWriteDataItem('CustLedgerEntry', CustLedgerEntry))
                {
                }
                trigger OnPreDataItem();
                begin
                    ReportForNav.OnPreDataItem('CustLedgerEntry', CustLedgerEntry);
                end;
                trigger OnAfterGetRecord();
                var CostCalcMgt: Codeunit "Cost Calculation Management";
                begin
                end;
            }
            trigger OnPreDataItem();
            begin
                ReportForNav.SetNewPagePerRecord('SalespersonPurchaser', Args."New Page per Person");
                ReportForNav.OnPreDataItem('SalespersonPurchaser', SalespersonPurchaser);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(NewPagePerPerson;Args."New Page per Person")
                    {
                        ApplicationArea = All;
                        Caption = 'New Page per Person';
                    }
                    field(ForNavOpenDesigner;ReportForNavOpenDesigner)
                    {
                        ApplicationArea = All;
                        Caption = 'Design';
                        Visible = ReportForNavAllowDesign;

                        trigger OnValidate()begin
                            ReportForNav.LaunchDesigner(ReportForNavOpenDesigner);
                            CurrReport.RequestOptionsPage.Close();
                        end;
                    }
                }
            }
        }
        actions
        {
        }
        trigger OnOpenPage()begin
            ReportForNavOpenDesigner:=false;
        end;
    }
    trigger OnInitReport()begin
        ;
        ReportsForNavInit;
        Codeunit.Run(Codeunit::"ForNAV First Time Setup");
        Commit;
        LoadWatermark;
    end;
    trigger OnPostReport()begin
    end;
    local procedure LoadWatermark()var ForNAVSetup: Record "ForNAV Setup";
    OutStream: OutStream;
    begin
        ForNAVSetup.Get;
        ForNAVSetup.CalcFields(ForNAVSetup."List Report Watermark");
        if not ForNAVSetup."List Report Watermark".Hasvalue then exit;
        ReportForNav.LoadWatermarkImage(ForNAVSetup.GetListReportWatermark);
    end;
    trigger OnPreReport();
    begin
        ;
        ReportsForNavPre;
    end;
    // --> Reports ForNAV Autogenerated code - do not delete or modify
    var ReportForNavInitialized: Boolean;
    ReportForNavShowOutput: Boolean;
    ReportForNavTotalsCausedBy: Boolean;
    ReportForNavOpenDesigner: Boolean;
    [InDataSet]
    ReportForNavAllowDesign: Boolean;
    ReportForNav: Codeunit "ForNAV Report Management";
    local procedure ReportsForNavInit()var id: Integer;
    begin
        Evaluate(id, CopyStr(CurrReport.ObjectId(false), StrPos(CurrReport.ObjectId(false), ' ') + 1));
        ReportForNav.OnInit(id, ReportForNavAllowDesign);
    end;
    local procedure ReportsForNavPre()begin
        if ReportForNav.LaunchDesigner(ReportForNavOpenDesigner)then CurrReport.Quit();
    end;
    local procedure ReportForNavSetTotalsCausedBy(value: Boolean)begin
        ReportForNavTotalsCausedBy:=value;
    end;
    local procedure ReportForNavSetShowOutput(value: Boolean)begin
        ReportForNavShowOutput:=value;
    end;
    local procedure ReportForNavInit(jsonObject: JsonObject)begin
        ReportForNav.Init(jsonObject, CurrReport.ObjectId);
    end;
    local procedure ReportForNavWriteDataItem(dataItemId: Text;
    rec: Variant): Text var values: Text;
    jsonObject: JsonObject;
    currLanguage: Integer;
    begin
        if not ReportForNavInitialized then begin
            jsonObject.Add('SalespersonPurchaser$Get$Filters$Text', SalespersonPurchaser.GetFilters());
            jsonObject.Add('SalespersonPurchaser$Get$Caption$Text', SalespersonPurchaser.TableCaption());
            jsonObject.Add('CustLedgerEntry$Get$Filters$Text', CustLedgerEntry.GetFilters());
            jsonObject.Add('CustLedgerEntry$Get$Caption$Text', CustLedgerEntry.TableCaption());
            ReportForNavInit(jsonObject);
            ReportForNavInitialized:=true;
        end;
        case(dataItemId)of end;
        ReportForNav.AddDataItemValues(jsonObject, dataItemId, rec);
        jsonObject.WriteTo(values);
        exit(values);
    end;
// Reports ForNAV Autogenerated code - do not delete or modify -->
}

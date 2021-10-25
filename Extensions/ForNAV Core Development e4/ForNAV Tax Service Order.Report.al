Report 6188611 "ForNAV Tax Service Order"
{
    Caption = 'Service Order';
    WordLayout = './Layouts/ForNAV Tax Service Order.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(Header;"Service Header")
        {
            DataItemTableView = sorting("No.")where("Document Type"=const(Order));
            MaxIteration = 1;
            RequestFilterFields = "No.", "Posting Date";

            column(ReportForNavId_2;2)
            {
            } // Autogenerated by ForNav - Do not delete
            column(ReportForNav_Header;ReportForNavWriteDataItem('Header', Header))
            {
            }
            column(HasDiscount;ForNAVCheckDocumentDiscount.HasDiscount(Header))
            {
            IncludeCaption = false;
            }
            dataitem(ItemLine;"Service Item Line")
            {
                DataItemLink = "Document Type"=FIELD("Document Type"), "Document No."=FIELD("No.");
                DataItemLinkReference = Header;
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");

                column(ReportForNavId_1;1)
                {
                } // Autogenerated by ForNav - Do not delete
                column(ReportForNav_ItemLine;ReportForNavWriteDataItem('ItemLine', ItemLine))
                {
                }
                dataitem(ServiceCommentLine;"Service Comment Line")
                {
                    DataItemLink = "Table Subtype"=FIELD("Document Type"), "No."=FIELD("Document No."), "Table Line No."=FIELD("Line No.");
                    DataItemTableView = sorting("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.")where("Table Name"=const("Service Header"), Type=filter(Fault|Resolution));

                    column(ReportForNavId_1000000003;1000000003)
                    {
                    } // Autogenerated by ForNav - Do not delete
                    column(ReportForNav_ServiceCommentLine;ReportForNavWriteDataItem('ServiceCommentLine', ServiceCommentLine))
                    {
                    }
                    trigger OnPreDataItem();
                    begin
                        ReportForNav.OnPreDataItem('ServiceCommentLine', ServiceCommentLine);
                    end;
                }
                trigger OnPreDataItem();
                begin
                    ReportForNav.OnPreDataItem('ItemLine', ItemLine);
                end;
            }
            dataitem(Line;"Service Line")
            {
                DataItemLink = "Document Type"=FIELD("Document Type"), "Document No."=FIELD("No.");
                DataItemLinkReference = Header;
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");

                column(ReportForNavId_3;3)
                {
                } // Autogenerated by ForNav - Do not delete
                column(ReportForNav_Line;ReportForNavWriteDataItem('Line', Line))
                {
                }
                trigger OnPreDataItem();
                begin
                    ReportForNav.OnPreDataItem('Line', Line);
                end;
            }
            dataitem(SalesTaxBuffer;"ForNAV Sales Tax Buffer")
            {
                DataItemTableView = sorting("Primary Key");
                UseTemporary = true;

                column(ReportForNavId_4;4)
                {
                } // Autogenerated by ForNav - Do not delete
                column(ReportForNav_SalesTaxBuffer;ReportForNavWriteDataItem('SalesTaxBuffer', SalesTaxBuffer))
                {
                }
                trigger OnPreDataItem();
                begin
                    ReportForNav.OnPreDataItem('SalesTaxBuffer', SalesTaxBuffer);
                end;
            }
            trigger OnPreDataItem();
            begin
                ReportForNav.OnPreDataItem('Header', Header);
            end;
            trigger OnAfterGetRecord();
            begin
                ChangeLanguage("Language Code");
                GetSalesTaxDetails;
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

                    field(NoOfCopies;NoOfCopies)
                    {
                        ApplicationArea = All;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies how many copies of the document to print.';
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
        ReportForNavOpenDesigner:=ReportForNavAllowDesign;
    end;
    trigger OnPostReport()begin
    end;
    trigger OnPreReport()var ForNAVSetup: Record "ForNAV Setup";
    begin
        ;
        ReportForNav.SetCopies('Header', NoOfCopies);
        LoadWatermark;
        ;
        ReportsForNavPre;
    end;
    var ForNAVCheckDocumentDiscount: Codeunit "ForNAV Check Document Discount";
    NoOfCopies: Integer;
    local procedure ChangeLanguage(LanguageCode: Code[10])var ForNAVSetup: Record "ForNAV Setup";
    begin
        ForNAVSetup.Get;
        if ForNAVSetup."Inherit Language Code" then CurrReport.Language(ReportForNav.GetLanguageID(LanguageCode));
    end;
    local procedure GetSalesTaxDetails()var ForNAVGetSalesTaxDetails: Codeunit "ForNAV Get Sales Tax Details";
    begin
        SalesTaxBuffer.DeleteAll;
        ForNAVGetSalesTaxDetails.GetSalesTax(Header, SalesTaxBuffer);
    end;
    local procedure LoadWatermark()var ForNAVSetup: Record "ForNAV Setup";
    OutStream: OutStream;
    begin
        ForNAVSetup.Get;
        if not PrintLogo(ForNAVSetup)then exit;
        ForNAVSetup.CalcFields(ForNAVSetup."Document Watermark");
        if not ForNAVSetup."Document Watermark".Hasvalue then exit;
        ReportForNav.LoadWatermarkImage(ForNAVSetup.GetDocumentWatermark);
    end;
    procedure PrintLogo(ForNAVSetup: Record "ForNAV Setup"): Boolean begin
        if not ForNAVSetup."Use Preprinted Paper" then exit(true);
        if 'Pdf' = 'PDF' then exit(true);
        if 'Pdf' = 'Preview' then exit(true);
        exit(false);
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
            ReportForNavInit(jsonObject);
            ReportForNavInitialized:=true;
        end;
        case(dataItemId)of 'Header': begin
            jsonObject.Add('CurrReport$Language$Integer', CurrReport.Language);
        end;
        end;
        ReportForNav.AddDataItemValues(jsonObject, dataItemId, rec);
        jsonObject.WriteTo(values);
        exit(values);
    end;
// Reports ForNAV Autogenerated code - do not delete or modify -->
}

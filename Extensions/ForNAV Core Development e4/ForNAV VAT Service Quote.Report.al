Report 6188479 "ForNAV VAT Service Quote"
{
    Caption = 'Service Quote';
    UsageCategory = ReportsAndAnalysis;
    WordLayout = './Layouts/ForNAV VAT Service Quote.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(Header;"Service Header")
        {
            RequestFilterFields = "No.", "Posting Date";
            MaxIteration = 1;
            DataItemTableView = sorting("No.")where("Document Type"=const(Quote));

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
            column(SingleVATPct;VATAmountLine.ForNavSingleVATPct())
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
            dataitem(VATAmountLine;"VAT Amount Line")
            {
                UseTemporary = true;
                DataItemTableView = sorting("VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Use Tax", Positive);

                column(ReportForNavId_1000000001;1000000001)
                {
                } // Autogenerated by ForNav - Do not delete
                column(ReportForNav_VATAmountLine;ReportForNavWriteDataItem('VATAmountLine', VATAmountLine))
                {
                }
                trigger OnPreDataItem();
                begin
                    if not PrintVATAmountLines then CurrReport.Break;
                    ReportForNav.OnPreDataItem('VATAmountLine', VATAmountLine);
                end;
            }
            dataitem(VATClause;"VAT Clause")
            {
                UseTemporary = true;
                DataItemTableView = sorting(Code);

                column(ReportForNavId_1000000002;1000000002)
                {
                } // Autogenerated by ForNav - Do not delete
                column(ReportForNav_VATClause;ReportForNavWriteDataItem('VATClause', VATClause))
                {
                }
                trigger OnPreDataItem();
                begin
                    ReportForNav.OnPreDataItem('VATClause', VATClause);
                end;
            }
            trigger OnPreDataItem();
            begin
                ReportForNav.OnPreDataItem('Header', Header);
            end;
            trigger OnAfterGetRecord();
            begin
                ChangeLanguage("Language Code");
                GetVatAmountLines;
                GetVATClauses;
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
    local procedure GetVatAmountLines()var ForNAVGetVatAmountLines: Codeunit "ForNAV Get Vat Amount Lines";
    begin
        VATAmountLine.DeleteAll;
        ForNAVGetVatAmountLines.GetVatAmountLines(Header, VATAmountLine);
    end;
    local procedure GetVATClauses()var ForNAVGetVatClause: Codeunit "ForNAV Get Vat Clause";
    begin
        VATClause.DeleteAll;
        ForNAVGetVatClause.GetVATClauses(VATAmountLine, VATClause, Header."Language Code");
    end;
    local procedure PrintVATAmountLines(): Boolean var ForNAVSetup: Record "ForNAV Setup";
    begin
        ForNAVSetup.Get;
        case ForNAVSetup."VAT Report Type" of ForNAVSetup."vat report type"::Always: exit(true);
        ForNAVSetup."vat report type"::"Multiple Lines": exit(VATAmountLine.Count > 1);
        ForNAVSetup."vat report type"::Never: exit(false);
        end;
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
    ReportForNavTotalsCausedBy: Integer;
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
    local procedure ReportForNavSetTotalsCausedBy(value: Integer)begin
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

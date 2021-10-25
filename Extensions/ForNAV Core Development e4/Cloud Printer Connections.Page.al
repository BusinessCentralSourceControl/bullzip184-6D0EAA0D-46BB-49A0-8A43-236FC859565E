page 6188474 "Cloud Printer Connections"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "ForNAV Cloud Printer Conn.";
    UsageCategory = ReportsAndAnalysis;
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Cloud Printer";Rec."Cloud Printer")
                {
                    ApplicationArea = All;
                }
                field("Service";Rec.Service)
                {
                    ApplicationArea = All;
                }
                field("Local Printer";Rec."Local Printer")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()begin
                end;
            }
        }
    }
    var myInt: Integer;
}

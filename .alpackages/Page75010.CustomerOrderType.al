page 75010 "Customer Order Type"
{
    ApplicationArea = All;
    Caption = 'Customer Order Type';
    PageType = List;
    SourceTable = "Customer Order Type";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Sell To Customer No."; Rec."Sell To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell To Customer  No. field.';
                }
                field("Sell To Customer Name"; Rec."Sell To Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell To Customer Name field.';
                }
                field("Bill To Customer No."; Rec."Bill To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill To Customer No. field.';
                }
                field("Bill To Customer Name"; Rec."Bill To Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill To Customer Name field.';
                }
                field("Order Type"; Rec."Order Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Type field.';
                }
                field(UOM; Rec.UOM)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UOM field.';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Date field.';
                }
                field("Created Time"; Rec."Created Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Time field.';
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remarks field.';
                }
                field("Active Yes/No"; Rec."Active Yes/No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active Yes/No field.';
                }
            }
        }
    }

    actions
    {
        area("Processing")
        {
            action(XmlImportCustomer)
            {
                ApplicationArea = all;
                Caption = 'Customer Order Type Im';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                trigger onAction()
                var

                begin

                    Xmlport.Run(75002, false, true);

                end;

            }
        }
    }



}

page 75005 "Item Category App"
{
    ApplicationArea = All;
    Caption = 'Item Category App';
    PageType = List;
    SourceTable = "Item Category App";
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
                    //Editable = False;
                }

                field("Catagory Code"; Rec."Catagory Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Catagory Code field.';
                }
                field("Catagory Name"; Rec."Catagory Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Catagory Name field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }

                field(Remark; Rec.Remark)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remark field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ShowTotalCount)
            {
                ApplicationArea = all;
                Caption = 'Show Total Count';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                trigger onAction()
                var

                begin

                    Message('Total Record(s)  %1 ', Rec.Count);

                end;
            }
        }
    }
}

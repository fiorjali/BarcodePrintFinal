page 75006 "Item Master App"
{
    ApplicationArea = All;
    Caption = 'Item Master App';
    PageType = List;
    SourceTable = "Item Master App";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Item Size"; Rec."Item Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Size field.';
                }
                field(Remark; Rec.Remark)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remark field.';
                }
                field("Catagory Code"; Rec."Catagory Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Catagory Code field.';
                }
                field("Image URL"; Rec."Image URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Image URL field.';
                }
            }
        }
    }
    actions
    {
        area("Processing")
        {
            action(XmlIMport)
            {
                ApplicationArea = all;
                Caption = 'Item Master Import';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                trigger onAction()
                var

                begin

                    Xmlport.Run(75000, false, true);

                end;

            }
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

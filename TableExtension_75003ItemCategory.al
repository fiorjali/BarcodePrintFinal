tableextension 75003 ItemCategoryExt extends "Item Category"
{

    fields
    {
        field(75001; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = ToBeClassified;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
            //CaptionML=[ENU=Sales-to Customer No.];
        }
        field(75002; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure";
            //CaptionML=[ENU=Sales-to Customer No.];
        }

    }
}
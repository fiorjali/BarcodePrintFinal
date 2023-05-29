page 75007 SaleOrderExport
{
    ApplicationArea = All;
    Caption = 'SaleOrderExport';
    PageType = List;
    SourceTable = SaleOrderExport;
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(General)
            {

                field("Entry No.";
                Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field(S_75; Rec.S_75)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the S_75 field.';
                }
                field(S_80S; Rec.S_80S)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the S_80S field.';
                }
                field(S_85M; Rec.S_85M)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the S_85M field.';
                }
                field(S_90L; Rec.S_90L)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the S_90L field.';
                }
                field(S_95XL; Rec.S_95XL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the S_95XL field.';
                }
                field(S_1002XL; Rec.S_1002XL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the S_1002XL field.';
                }
                field(S_1053XL; Rec.S_1053XL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the S_1053XL field.';
                }
                field(S_1104XL; Rec.S_1104XL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the S_1104XL field.';
                }
                field(S_1155XL; Rec.S_1155XL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the S_1155XL field.';
                }
                field(totaQty; Rec."Tota Qty")
                {
                    Caption = 'Tota Qty';
                }
                field("Select Order Type"; Rec."Select Order Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Select Order Type field.';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Category Code field.';
                }
                field(Remark; Rec.Remark)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remark field.';
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
                field("Accepted Date"; Rec."Accepted Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Accepted Date field.';
                }
                field("Accepted Time"; Rec."Accepted Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Accepted Time field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Sale Order No."; Rec."Sale Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Order No. field.';
                }

                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. field.';
                }
                field("Order Type"; Rec."Order Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Type field.';
                }
                field("Bill To Customer"; Rec."Bill To Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill To Customer field.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field.';
                }



            }
        }
    }





    actions
    {
        // Adds the action called "My Actions" to the Action menu 
        area(Processing)
        {
            action("Create Sale Order")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    OK: Boolean;
                    SalesHeaderRec: Record 36;
                    SalesLineRec: Record 37;
                    SaleOrderExportRec: Record "SaleOrderExport";
                    CustomerRec: Record 18;
                    LineNo: Integer;
                    ItemRec: Record 27;
                    SaleOrderExportRecNew: Record "SaleOrderExport";
                    FilterDocument: Code[20];
                    CharIndex: Integer;
                    FilterDocumentMax: Code[250];
                    SelectOrderType: Text[100];
                begin

                    OK := CONFIRM('Are you sure to Create a Sale Order', TRUE, FALSE);

                    IF NOT OK THEN
                        EXIT;


                    CharIndex := 0;
                    FilterDocumentMax := Rec.GETFILTER("Document No.");
                    CharIndex := STRPOS(FilterDocumentMax, '|');

                    IF (CharIndex <> 0) THEN BEGIN
                        ERROR('You can select only one Document in one time.\Filter Document No. \' + FilterDocumentMax);
                    END;


                    FilterDocument := Rec.GETFILTER("Document No.");


                    IF (FilterDocument = '') THEN BEGIN
                        ERROR('There is no document filtered %1 ', CharIndex);
                    END;

                    //,Pluse Balance,New Order (Balance Cancel)

                    //CurrPage.SETSELECTIONFILTER(SaleOrderExportRecNew);

                    // MESSAGE('%1',SaleOrderExportRecNew.COUNT);
                    //
                    // IF SaleOrderExportRecNew.FINDFIRST THEN BEGIN
                    //  SelectOrderType :=FORMAT(SaleOrderExportRecNew."Select Order Type");
                    //
                    //  MESSAGE(SelectOrderType);
                    // END;

                    SaleOrderExportRecNew.RESET;
                    SaleOrderExportRecNew.SETRANGE(Status, SaleOrderExportRecNew.Status::Pending);
                    SaleOrderExportRecNew.SETFILTER("Document No.", FilterDocument);
                    IF SaleOrderExportRecNew.FINDFIRST THEN BEGIN
                        SelectOrderType := FORMAT(SaleOrderExportRecNew."Select Order Type");
                        ///Pluse Balance  = 0
                        IF SelectOrderType = 'Pluse Balance' THEN BEGIN
                            //UpdateBalanceSaleOrder();
                            CopyBlanceOrder(SaleOrderExportRecNew."Document No.");
                        END ELSE BEGIN
                            CreateNewSaleOrder();
                        END;
                    END ELSE BEGIN
                        ERROR('Data Not Found With in Below Filter \' + SaleOrderExportRecNew.GETFILTERS());
                    END;

                end;
            }

            action(XmlIMport)
            {
                ApplicationArea = all;
                Caption = 'Xml Import';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                trigger onAction()
                var

                begin

                    Xmlport.Run(75003, false, true);

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





    PROCEDURE CopyBlanceOrder(DocumentNo: Code[20]);
    VAR
        MyDialog: Dialog;
        SalesHeader: Record 36;
        SLineRec: Record 37;
        LastLineNo: Integer;
        i: Integer;
        Flg: Boolean;
        J: Integer;
        DocNoArr: ARRAY[20] OF Code[20];
        k: Integer;
        PickHeaderRec: Record "Warehouse Activity Header";
        SalesLine1: Record "Sales Line";
        SaLnUpdateRec: Record "Sales Line";
        SHeaderRec: Record "Sales Header";
        SaleToCust: Code[20];
        BillToCust: Code[20];
        CustomerRec: Record "Customer";
        SaleOrderExportFind: Record "SaleOrderExport";
        ItemCategoryRec: Record "Item Category";
        LocationCode: Code[20];
        SaleOrderExportRec: Record "SaleOrderExport";
        ItemRec: Record "Item";
        SalesLineRec: Record "Sales Line";
        TotalLine: Integer;
    begin
        //Copy Sales Order

        SaleOrderExportFind.RESET;
        SaleOrderExportFind.SETRANGE("Document No.", DocumentNo);
        SaleOrderExportFind.SETRANGE(Status, SaleOrderExportFind.Status::Pending);

        LocationCode := '';
        IF SaleOrderExportFind.FINDFIRST THEN BEGIN

            ItemCategoryRec.RESET;
            ItemCategoryRec.SETRANGE(Code, SaleOrderExportFind."Item Category Code");
            IF ItemCategoryRec.FINDFIRST THEN;
            LocationCode := ItemCategoryRec."Location Code";

            SaleToCust := SaleOrderExportFind."Customer No.";
            IF SaleToCust <> '' THEN BEGIN
                IF CustomerRec.GET(SaleToCust) THEN BEGIN
                    BillToCust := CustomerRec."Bill-to Customer No.";
                END ELSE BEGIN
                    ERROR('Custome Code ' + SaleToCust + 'Not Found in customer Master');
                END;
            END ELSE BEGIN
                ERROR('SaleToCust Code Can not left Blank ');
            END;


            MESSAGE('Selle to Cust %1 And Bill to Cust %2', SaleToCust, BillToCust);

            IF (LocationCode = '') THEN BEGIN
                ERROR('Location Code is blank in Item Category %1', SaleOrderExportFind."Item Category Code");
            END;

            MyDialog.OPEN('Copying  Blance Order...');
            SalesHeader.SETCURRENTKEY("Short Close", Closed, "Exclude CalcBaln");
            SalesHeader.SETRANGE("Order Date", 20220401D, TODAY);
            SalesHeader.SETRANGE("Short Close", FALSE);
            SalesHeader.SETRANGE("Exclude CalcBaln", FALSE);
            SalesHeader.SETRANGE(Closed, FALSE);
            SalesHeader.SETRANGE("Sell-to Customer No.", SaleToCust);
            SalesHeader.SETRANGE("Bill-to Customer No.", BillToCust);
            SalesHeader.SETRANGE("Location Code", LocationCode);
            IF SalesHeader.FINDFIRST THEN BEGIN
                SLineRec.RESET;
                SLineRec.SETRANGE(SLineRec."Document Type", SLineRec."Document Type"::Order);
                SLineRec.SETRANGE(SLineRec."Document No.", SalesHeader."No.");
                SLineRec.SETRANGE("Order Date", 20220401D, TODAY);
                IF SLineRec.FINDLAST THEN
                    LastLineNo := SLineRec."Line No."
                ELSE
                    LastLineNo := 10000;
            END;

            //***************************

            SaleOrderExportRec.RESET;
            SaleOrderExportRec.SETRANGE("Document No.", DocumentNo);

            // MESSAGE('%1',SaleOrderExportRec.COUNT);
            SaleOrderExportRec.SETRANGE(Status, SaleOrderExportRec.Status::Pending);

            IF NOT SaleOrderExportRec.FINDFIRST THEN
                ERROR('There is NO data found with below filter\' + SaleOrderExportRec.GETFILTERS);

            TotalLine := 0;
            IF SaleOrderExportRec.FINDFIRST THEN
                REPEAT
                    CustomerRec.RESET;
                    CustomerRec.SETRANGE("Web Portal User Name", SaleOrderExportRec."Customer No.");
                    IF CustomerRec.FINDFIRST THEN BEGIN
                        IF SaleOrderExportRec."Tota Qty" <> 0 THEN BEGIN
                            ItemRec.RESET;
                            ItemRec.SETRANGE("No.", SaleOrderExportRec."Item No.");
                            IF ItemRec.FINDFIRST THEN;

                            //IF SalesHeaderRec.MODIFY(TRUE) THEN BEGIN
                            IF SaleOrderExportRec.S_75 <> 0 THEN BEGIN
                                LastLineNo += 10000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeader."No.";
                                SalesLineRec."Line No." := LastLineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '75');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_75);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                TotalLine += 1;
                            END;

                            IF SaleOrderExportRec.S_80S <> 0 THEN BEGIN
                                LastLineNo += 10000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeader."No.";
                                SalesLineRec."Line No." := LastLineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '80');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_80S);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                TotalLine += 1;
                            END;

                            IF SaleOrderExportRec.S_85M <> 0 THEN BEGIN
                                LastLineNo += 10000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeader."No.";
                                SalesLineRec."Line No." := LastLineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '85');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_85M);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                TotalLine += 1;
                            END;

                            IF SaleOrderExportRec.S_90L <> 0 THEN BEGIN
                                LastLineNo += 10000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeader."No.";
                                SalesLineRec."Line No." := LastLineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '90');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_90L);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                TotalLine += 1;
                            END;

                            IF SaleOrderExportRec.S_95XL <> 0 THEN BEGIN
                                LastLineNo += 10000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeader."No.";
                                SalesLineRec."Line No." := LastLineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '95');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_95XL);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                TotalLine += 1;
                            END;

                            IF SaleOrderExportRec.S_1002XL <> 0 THEN BEGIN
                                LastLineNo += 10000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeader."No.";
                                SalesLineRec."Line No." := LastLineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '100');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_1002XL);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                TotalLine += 1;
                            END;

                            IF SaleOrderExportRec.S_1053XL <> 0 THEN BEGIN
                                LastLineNo += 10000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeader."No.";
                                SalesLineRec."Line No." := LastLineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '105');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_1053XL);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                TotalLine += 1;
                            END;

                            IF SaleOrderExportRec.S_1104XL <> 0 THEN BEGIN
                                LastLineNo += 10000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeader."No.";
                                SalesLineRec."Line No." := LastLineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '110');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_1104XL);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523  SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                TotalLine += 1;
                            END;

                            IF SaleOrderExportRec.S_1155XL <> 0 THEN BEGIN
                                LastLineNo += 10000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeader."No.";
                                SalesLineRec."Line No." := LastLineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '115');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_1155XL);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                TotalLine += 1;
                            END;

                            SaleOrderExportRec.Status := SaleOrderExportRec.Status::Accepted;
                            SaleOrderExportRec."Accepted Date" := TODAY;
                            SaleOrderExportRec."Accepted Time" := TIME;
                            SaleOrderExportRec."Sale Order No." := SalesHeader."No.";
                            SaleOrderExportRec.MODIFY(TRUE);

                            //END;
                        END ELSE BEGIN
                            ERROR('All Size Total Quantity is zero');
                        END;
                    END ELSE BEGIN
                        ERROR('Customer NO. %1 not Mapped in any Customer Master');
                    END;

                UNTIL SaleOrderExportRec.NEXT = 0;
            IF SaleOrderExportRec.FINDFIRST THEN;
            MESSAGE('Total Line Processed is %1 Out Of %2 ', TotalLine, SaleOrderExportRec.COUNT);
            //***************************

            MyDialog.CLOSE();
        END ELSE BEGIN
            ERROR('Error');
        END;
    END;

    LOCAL PROCEDURE CreateNewSaleOrder();
    VAR
        OK: Boolean;
        SalesHeaderRec: Record 36;
        SalesLineRec: Record 37;
        SaleOrderExportRec: Record "SaleOrderExport";
        CustomerRec: Record 18;
        LineNo: Integer;
        ItemRec: Record 27;
        ItemCategoryRec: Record 5722;
        LocationCode: Code[20];
        HeaderFlg: Boolean;
        FilterDocumentNo: Code[20];
        TotaQty: Decimal;
        HeaderInsertFlg: Boolean;
        LineInsertFlg: Integer;
        CustomerOrderTypeRec: Record "Customer Order Type";
    BEGIN

        MESSAGE('Filter Document No %1 ', Rec.GETFILTER("Document No."));

        FilterDocumentNo := Rec.GETFILTER("Document No.");

        SaleOrderExportRec.RESET;
        //CurrPage.SETSELECTIONFILTER(SaleOrderExportRec);
        // MESSAGE('%1',SaleOrderExportRec.COUNT);
        SaleOrderExportRec.SETRANGE(Status, SaleOrderExportRec.Status::Pending);
        SaleOrderExportRec.SETFILTER("Document No.", FilterDocumentNo);
        IF NOT SaleOrderExportRec.FINDFIRST THEN BEGIN
            ERROR('There is NO data found with below filter\' + SaleOrderExportRec.GETFILTERS);
        END ELSE BEGIN
            ItemCategoryRec.RESET;
            ItemCategoryRec.SETRANGE(Code, SaleOrderExportRec."Item Category Code");
            IF ItemCategoryRec.FINDFIRST THEN;
            LocationCode := ItemCategoryRec."Location Code";
        END;

        IF (LocationCode = '') THEN BEGIN
            ERROR('Location Code is blank in Item Category %1', SaleOrderExportRec."Item Category Code");
        END;


        TotaQty := 0;

        IF SaleOrderExportRec.FINDFIRST THEN
            REPEAT
                TotaQty += SaleOrderExportRec."Tota Qty";
            UNTIL SaleOrderExportRec.NEXT = 0;

        HeaderFlg := FALSE;


        IF (TotaQty = 0) THEN BEGIN
            HeaderFlg := FALSE;
        END ELSE BEGIN
            HeaderFlg := TRUE;
        END;

        HeaderInsertFlg := FALSE;

        IF SaleOrderExportRec.FINDFIRST THEN BEGIN
            IF (HeaderFlg = TRUE) AND (TotaQty <> 0) THEN BEGIN
                SalesHeaderRec.INIT;
                SalesHeaderRec.VALIDATE("Document Type", SalesHeaderRec."Document Type"::Order);
                SalesHeaderRec."No." := '';
                SalesHeaderRec.INSERT(TRUE);
                SalesHeaderRec.SetHideValidationDialog(TRUE);
                SalesHeaderRec.VALIDATE("Posting Date", TODAY);
                SalesHeaderRec.VALIDATE("Document Date", TODAY);
                SalesHeaderRec.VALIDATE("Sell-to Customer No.", SaleOrderExportRec."Customer No.");
                SalesHeaderRec.VALIDATE("Location Code", LocationCode);

                //Validate Bill To Customer No. If Not Default
                CustomerOrderTypeRec.RESET;
                CustomerOrderTypeRec.SETRANGE("Sell To Customer No.", SaleOrderExportRec."Customer No.");
                CustomerOrderTypeRec.SETRANGE("Order Type", SaleOrderExportRec."Order Type");
                IF CustomerOrderTypeRec.FINDFIRST THEN BEGIN
                    if (CustomerOrderTypeRec."Bill To Customer No." <> SaleOrderExportRec."Bill To Customer") then begin
                        SalesHeaderRec.Validate("Bill-to Customer No.", CustomerOrderTypeRec."Bill To Customer No.");
                    end;
                END;


                IF SalesHeaderRec.MODIFY(TRUE) THEN BEGIN
                    HeaderInsertFlg := TRUE;
                END ELSE BEGIN
                    HeaderInsertFlg := FALSE;
                END;
            END ELSE BEGIN
                ERROR('Sales Order is not created Because of Douemnt No. %1 Total Quantity is %2 Zero', FilterDocumentNo, TotaQty);
            END;
        END;


        IF (HeaderInsertFlg = TRUE) THEN BEGIN
            LineNo := 10000;
            LineInsertFlg := 0;
            IF SaleOrderExportRec.FINDFIRST THEN
                REPEAT
                    IF SaleOrderExportRec."Tota Qty" <> 0 THEN BEGIN

                        ItemRec.RESET;
                        ItemRec.SETRANGE("No.", SaleOrderExportRec."Item No.");
                        IF ItemRec.FINDFIRST THEN;

                        IF SalesHeaderRec.MODIFY(TRUE) THEN BEGIN
                            IF SaleOrderExportRec.S_75 <> 0 THEN BEGIN
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeaderRec."No.";
                                SalesLineRec."Line No." := LineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '75');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_75);
                                //SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Base Unit of Measure");
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");

                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeaderRec."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                LineNo += 10000;
                                LineInsertFlg += 1;
                            END;

                            IF SaleOrderExportRec.S_80S <> 0 THEN BEGIN
                                //LineNo:=20000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeaderRec."No.";
                                SalesLineRec."Line No." := LineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '80');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_80S);
                                //SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Base Unit of Measure");
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");

                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeaderRec."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                LineNo += 10000;
                                LineInsertFlg += 1;
                            END;

                            IF SaleOrderExportRec.S_85M <> 0 THEN BEGIN
                                //LineNo:=30000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeaderRec."No.";
                                SalesLineRec."Line No." := LineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '85');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_85M);
                                //SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Base Unit of Measure");
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeaderRec."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                LineNo += 10000;
                                LineInsertFlg += 1;
                            END;

                            IF SaleOrderExportRec.S_90L <> 0 THEN BEGIN
                                //LineNo:=40000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeaderRec."No.";
                                SalesLineRec."Line No." := LineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '90');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_90L);
                                //SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Base Unit of Measure");
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");

                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeaderRec."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                LineNo += 10000;
                                LineInsertFlg += 1;
                            END;

                            IF SaleOrderExportRec.S_95XL <> 0 THEN BEGIN
                                //LineNo:=50000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeaderRec."No.";
                                SalesLineRec."Line No." := LineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_95XL);
                                SalesLineRec.VALIDATE("Variant Code", '95');
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeaderRec."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                LineNo += 10000;
                                LineInsertFlg += 1;
                            END;

                            IF SaleOrderExportRec.S_1002XL <> 0 THEN BEGIN
                                //LineNo:=60000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeaderRec."No.";
                                SalesLineRec."Line No." := LineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '100');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_1002XL);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeaderRec."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                LineNo += 10000;
                                LineInsertFlg += 1;
                            END;

                            IF SaleOrderExportRec.S_1053XL <> 0 THEN BEGIN
                                //LineNo:=70000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeaderRec."No.";
                                SalesLineRec."Line No." := LineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '105');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_1053XL);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeaderRec."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                LineNo += 10000;
                                LineInsertFlg += 1;
                            END;

                            IF SaleOrderExportRec.S_1104XL <> 0 THEN BEGIN
                                //LineNo:=80000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeaderRec."No.";
                                SalesLineRec."Line No." := LineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '110');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_1104XL);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeaderRec."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                LineNo += 10000;
                                LineInsertFlg += 1;
                            END;

                            IF SaleOrderExportRec.S_1155XL <> 0 THEN BEGIN
                                //LineNo:=90000;
                                SalesLineRec.INIT;
                                SalesLineRec."Document Type" := SalesLineRec."Document Type"::Order;
                                SalesLineRec."Document No." := SalesHeaderRec."No.";
                                SalesLineRec."Line No." := LineNo;
                                //SalesLineRec.INSERT(TRUE);
                                SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
                                SalesLineRec.VALIDATE("No.", SaleOrderExportRec."Item No.");
                                SalesLineRec.VALIDATE("Variant Code", '115');
                                SalesLineRec.VALIDATE(Quantity, SaleOrderExportRec.S_1155XL);
                                SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");
                                //FC 270523 SalesLineRec.VALIDATE("Sell-to Customer No.", SalesHeaderRec."Sell-to Customer No.");
                                //SalesLineRec.MODIFY(TRUE);
                                SalesLineRec.INSERT(TRUE);
                                LineNo += 10000;
                                LineInsertFlg += 1;
                            END;

                            SaleOrderExportRec.Status := SaleOrderExportRec.Status::Accepted;
                            SaleOrderExportRec."Accepted Date" := TODAY;
                            SaleOrderExportRec."Accepted Time" := TIME;
                            SaleOrderExportRec."Sale Order No." := SalesHeaderRec."No.";
                            SaleOrderExportRec.MODIFY(TRUE);
                        END;
                    END ELSE BEGIN
                        ERROR('All Size Total Quant`ity is zero');
                    END;
                UNTIL SaleOrderExportRec.NEXT = 0;
        END;


        IF (HeaderInsertFlg = TRUE) THEN BEGIN
            IF SaleOrderExportRec.FINDFIRST THEN;
            MESSAGE('Sale Order Created SuccessFully!\For Total Procced Line is %1 out of %2 ', LineInsertFlg, SaleOrderExportRec.COUNT);
        END ELSE BEGIN
            MESSAGE('Sale Order not Created');
        END;
    END;



}

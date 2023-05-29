pageextension 75001 PurchaseOrderJson extends "Purchase Order List"
{
    actions

    {
        addlast("o&rder")
        {
            action(OrderJson)
            {
                ApplicationArea = all;
                Caption = 'Json Demo';
                Image = Document;

                trigger onAction()
                var
                    JsonText: Text;
                    JsonOutPut: Text;
                    i: Integer;
                    SalesPriceRec: Record "Sales Price";
                    InventorySetupRec: Record "Inventory Setup";
                    CU: Codeunit ProcessBarcodeITExpert;
                    CartonBarcode: Code[20];
                    SalesOrder: Code[20];
                    UserID: Code[50];
                    flg: Boolean;
                    input: JsonObject;
                    c: JsonToken;
                    Myresult: Text[1024];
                    Orderjson: JsonObject;
                    Message: Text[1024];
                    EndCode: Code[20];
                    SalesHeaderRec: Record "Sales Header";
                    ErrL: Text[1024];
                    WebUserRec: Record "Web User" temporary;
                    Client: HttpClient;
                    Response: HttpResponseMessage;
                    json: Text;
                    jsonObj: JsonObject;

                    DPCU: Codeunit "DistibutorPortal";
                    a: Integer;
                    b: Integer;
                    r: Integer;


                begin
                    CartonBarcode := '290323ST00155';
                    SalesOrder := 'ORD/2324/000013';
                    UserID := '	NEERAJ';

                    a := 23;
                    b := 7;
                    r := a / b;
                    r := a mod b;
                    Message('%1', r);

                    //json := DPCU.WebUserExport(UserID);
                    //json := DPCU.ItemCategoryExport();
                    //Message(json);

                    //RestAPITest();

                    //CU.ValidateCBarcode()
                    /* WebUserRec.Init();
                    WebUserRec."User ID" := 'Fiorj Ali';
                    WebUserRec.Password := '1234';
                    WebUserRec.Insert(True);
                    CLEARLASTERROR;
                    IF NOT CODEUNIT.RUN(CODEUNIT::"Create Customer", WebUserRec) THEN BEGIN
                        Message('Error Traped\' + GetLastErrorText());
                    END else begin
                        Message('Record is created No');
                    end;
                    //CLEARLASTERROR;

 */

                    //InsertWebUser(UserID, '1234');
                    //Test(10, 5, ErrL);
                    //if ErrL <> '' then
                    //    Message(ErrL);

                    //InsertDatainTable(Rec."Vendor Shipment No.", ErrL);

                    //if ErrL <> '' then
                    //     Message(ErrL);

                    //CU.RMPurchaseStockTake('');

                    //CartonBarcode := '290323ST00155';
                    //SalesOrder := '250423BI006192';
                    //SalesHeaderRec.Reset();
                    //SalesHeaderRec.SetRange("Document Type", SalesHeaderRec."Document Type"::Order);
                    //SalesHeaderRec.SetRange("No.", 'ORD/2324/000059');
                    if SalesHeaderRec.FindFirst() then begin
                        //Pack
                        //CU.ShipTOBarcode(SalesHeaderRec, '261122IV84775', ErrL, False, 123, 'B110', '290323ST00155');
                        //CU.ShipTOBarcode(SalesHeaderRec, '261122IV85010', ErrL, False, 123, 'B110', '290323ST00155');
                        //CU.ShipTOBarcode(SalesHeaderRec, '250622IV08043', ErrL, False, 123, 'B110', '290323ST00155');
                        //CU.ShipTOBarcode(SalesHeaderRec, '020123SE03520', ErrL, False, 123, 'B110', '250423BI006192');

                        //UnPack
                        //CU.ShipTOBarcode(SalesHeaderRec, '020123SE03520', ErrL, TRUE, 123, 'B110', '250423BI006192');
                    end;




                    //ValidateEndUser(EndCode, UserID, CartonBarcode, SalesOrder);
                    /* 
                                        Clear(Orderjson);
                                        System.ClearLastError();
                                        //CU.AssignBarcode(CartonBarcode, SalesOrder, UserID);
                                        //flg := Test(10, 5);
                                        //InsertDatainTable('1234567899876543212345664');

                                        //Message('Result is ' + format(flg));
                                        Message := GetLastErrorText();
                                        Orderjson.Add('id', '0');
                                        Orderjson.Add('Success', flg);
                                        Orderjson.Add('Message', Message);
                                        Orderjson.WriteTo(Myresult);
                                        Myresult := Myresult.Replace('\', '');
                                        Message(Myresult);

                                        Clear(Orderjson);
                                        System.ClearLastError();

                                        flg := Test(10, 0);
                                        Message := GetLastErrorText();
                                        Orderjson.Add('id', '0');
                                        Orderjson.Add('Success', flg);
                                        Orderjson.Add('Message', Message);
                                        Orderjson.WriteTo(Myresult);
                                        Myresult := Myresult.Replace('\', '');
                                        Message(Myresult);
                     */

                    //JsonText := '{"inputJson": "{\"PhyLotNo\":\"NA\",\"ItemNo\":\"1517W\",\"VariantCode\":\"85\",\"PrintReport\":\"2\",\"UOM\":\"BOX\",\"IssuedToUID\":\"A101\",\"No0fBarcodes\":\"2\",\"UOMMRP\":\"false\",\"PriceGroupCode\":\"MRP_22\",\"PurStndrdQty\":\"0\",\"CreatedBy\":\"POOJA\"}"}';
                    //JsonText := '{"inputJson": "{"PhyLotNo":"NA","ItemNo":"1517W","VariantCode":"85","PrintReport":"2","UOM":"BOX","IssuedToUID":"A101","No0fBarcodes":"2","UOMMRP":"false","PriceGroupCode":"MRP_22","PurStndrdQty":"0","CreatedBy":"POOJA"}"}';
                    //JsonText := JsonText.Replace('\"', '"');
                    //JsonOutPut := PBarCode.BarcodePrint(JsonText);
                    //JsonText := '"inputJson": "{\"str\":\"Hello world!\",\"confirm\":true}"';
                    //i := PBarCode.GetLengthOfStringWithConfirmation('');
                    /* InventorySetupRec.GET;
                    SalesPriceRec.RESET;
                    SalesPriceRec.SETRANGE("Item No.", '1517W');
                    SalesPriceRec.SETRANGE("Sales Type", SalesPriceRec."Sales Type"::"Customer Price Group");
                    SalesPriceRec.SETRANGE("Sales Code", 'MRP_22');
                    SalesPriceRec.SETRANGE("Variant Code", '85');
                    SalesPriceRec.SETRANGE("Unit of Measure Code", 'PCS');
                    if SalesPriceRec.FindFirst() then begin
                        Message('Unit Price =%1 MPR Price %2', SalesPriceRec."Unit Price", SalesPriceRec."MRP Price");
                    end; */

                    //Message(JsonOutPut);

                end;
            }
        }
    }

    [TryFunction]
    local procedure Test(i: Integer; J: Integer; var mm: Text[100])
    var
        r: Integer;
    begin


        r := i / j;
        //exit;

        //Message('%1', r);
        mm := Format(r);
        exit;

        if r = 0 then begin
            mm := 'Demo';
        end;
        // exit('Done');

    end;

    [TryFunction]
    local procedure InsertDatainTable(Barcode: Text[100]; var ErrorTxt: Text[100])
    var
        r: Integer;
        SCN: Record "Barcode Serial No.";
        MyDotNetExceptionHandler: Codeunit 1291;
    begin




        SCN.Init();
        SCN."Serial No." := Barcode;
        SCN.Insert();

        if GetLastErrorText() <> '' then begin
            ErrorTxt := GetLastErrorText();
        end else begin
            ErrorTxt := Barcode + 'Inserted Record inserted';
        end;

        MyDotNetExceptionHandler.Collect;
        MyDotNetExceptionHandler.Rethrow;


    end;



    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure InsertWebUser(UserID: Code[30]; UPass: Code[30])
    var
        myErrorInfo, myErrorInfo2 : ErrorInfo;
        WebUserRec: Record "Web User";
    //MyDotNetExceptionHandler: Codeunit 1291;

    begin
        WebUserRec.Init();
        WebUserRec."User ID" := UserID;
        WebUserRec.Password := UPass;
        WebUserRec.Insert(True);

        myErrorInfo.Collectible(true);
        //Error(myErrorInfo);
        //MyDotNetExceptionHandler.Collect;
        //MyDotNetExceptionHandler.Rethrow;
    end;

    procedure RestAPITest()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        json: Text;
        jsonObj: JsonObject;
    begin


    end;


}
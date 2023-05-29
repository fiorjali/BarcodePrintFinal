codeunit 75004 "DistibutorPortal"
{

    var

    trigger OnRun()
    var

    begin

    end;

    PROCEDURE ValidateWebUser(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        UserID: Code[50];
        PWS: Code[20];
        LoginType: Text[100];// 'Distributor,ASM/RSM'

        //Function Out
        ErrText: Text[250];
        UserName: Text[250];
        CustomerCode: Code[20];
        Flg: Boolean;

        WebUserRec: Record "Web User";


        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN

        input.ReadFrom(inputJson);
        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;
        //Get PWS
        if input.Get('PWS', c) then begin
            PWS := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'PWS Node not found in Payload');
            exit(Myresult);
        end;

        //Get LoginType
        if input.Get('LoginType', c) then begin
            LoginType := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'LoginType Node not found in Payload');
            exit(Myresult);
        end;


        WebUserRec.RESET;
        WebUserRec.SETRANGE("User ID", UserID);
        WebUserRec.SETRANGE(Password, PWS);
        if (LoginType = 'Distributor') then begin
            WebUserRec.SETRANGE("Login Type", WebUserRec."Login Type"::Distributor);
        end else begin
            WebUserRec.SETRANGE("Login Type", WebUserRec."Login Type"::"ASM/RSM");
        end;
        CustomerCode := '';

        IF WebUserRec.FINDFIRST THEN BEGIN
            IF WebUserRec."Active Yes/No" THEN BEGIN
                UserName := WebUserRec."User Name";
                //CustomerCode := WebUserRec."Sell-to Customer No.";
                CustomerCode := WebUserRec."Sales To Customer No.";
                ErrText := '';
                //EXIT(TRUE);
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', '');
                Orderjson.Add('UserName', UserName);
                Orderjson.Add('CustomerCode', CustomerCode);
                Orderjson.WriteTo(Myresult);
                exit(Myresult);
            END ELSE BEGIN
                UserName := WebUserRec."User Name";
                CustomerCode := WebUserRec."Sales To Customer No.";
                ErrText := 'User Not Active';
                //EXIT(FALSE);
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('Message', ErrText);
                Orderjson.Add('UserName', UserName);
                Orderjson.Add('CustomerCode', CustomerCode);
                Orderjson.WriteTo(Myresult);
                exit(Myresult);
            END;
        END ELSE BEGIN
            UserName := '';
            CustomerCode := '';
            ErrText := 'Invalid User ID';
            //EXIT(FALSE);
            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('Message', ErrText);
            Orderjson.Add('UserName', UserName);
            Orderjson.Add('CustomerCode', CustomerCode);
            Orderjson.WriteTo(Myresult);
            exit(Myresult);
        END;
    END;

    //************************* CreateJsonPayload ********************************
    procedure CreateJsonPayload(id: Text; Success: Text; Message: Text): Text[1024]
    var
        Orderjson: JsonObject;
        jsontext: Text[1024];
    begin
        Orderjson.Add('id', id);
        Orderjson.Add('Success', Success);
        Orderjson.Add('Message', Message);
        Orderjson.WriteTo(jsontext);
        jsontext := jsontext.Replace('\', '');
        exit(jsontext);
    end;


    //************************* ValidateWebCustomer ********************************
    PROCEDURE ValidateWebCustomer(inputJson: Text[2024]): Text[1024]
    VAR
        //Function In
        CustomerCode: Code[20];
        //Function Out
        ErrText: Text[250];
        eMailID: Text[100];
        MobileNo: Code[50];
        Flg: Boolean;

        CustomerRec: Record "Customer";

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
    BEGIN

        input.ReadFrom(inputJson);
        //Get CustomerCode
        if input.Get('CustomerCode', c) then begin
            CustomerCode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'CustomerCode Node not found in Payload');
            exit(Myresult);
        end;

        CustomerRec.RESET;
        CustomerRec.SETRANGE("No.", CustomerCode);
        IF CustomerRec.FINDFIRST THEN BEGIN
            //eMailID:=CustomerRec."E-Mail";
            //MobileNo := CustomerRec."Mobile No.";

            eMailID := 'firojalirahim@gmail.com';
            MobileNo := '9891456287';

            ErrText := '';
            //EXIT(TRUE);
            Orderjson.Add('id', '1');
            Orderjson.Add('Success', 'True');
            Orderjson.Add('Message', '');
            Orderjson.Add('eMailID', eMailID);
            Orderjson.Add('MobileNo', MobileNo);
            Orderjson.WriteTo(Myresult);
            exit(Myresult);
        END ELSE BEGIN
            eMailID := '';
            MobileNo := '';
            ErrText := 'Invalid User ID';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'CustomerCode', ErrText);
            exit(Myresult);
        END;
    END;

    //************************* ValidateWebCustomer ********************************
    PROCEDURE WebUserExport(inputJson: Text[2024]): Text
    var
        //Function In
        UserID: Code[20];
        //Function Out
        WebUserRec: Record "Web User";

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        WebUserJSON: JsonObject;
        jsontext: Text;
        FinalJsonTxt: Text;
        Cnt: Integer;
        I: Integer;

    BEGIN

        input.ReadFrom(inputJson);
        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;

        WebUserRec.RESET;
        WebUserRec.SETRANGE("User ID", UserID);
        //WebUserRec.SetFilter("User Name", UserID);

        Cnt := WebUserRec.Count;

        if Cnt > 1 then begin
            FinalJsonTxt := '[';
        end;
        I := 1;
        IF WebUserRec.FINDFIRST THEN begin
            repeat
                WebUserJSON.Add('No', WebUserRec."Sales To Customer No.");
                WebUserJSON.Add('Description', WebUserRec."Sell To customer Name");
                WebUserJSON.Add('UserID', WebUserRec."User ID");
                WebUserJSON.WriteTo(jsontext);
                if (I > 1) then begin
                    FinalJsonTxt += ',' + jsontext;
                end else begin
                    FinalJsonTxt += jsontext;
                end;
                jsontext := '';
                Clear(WebUserJSON);
                I += 1;
            until WebUserRec.Next() = 0;

        end;
        if Cnt > 1 then begin
            FinalJsonTxt := FinalJsonTxt + ']';
        end;

        //EXIT(TRUE);
        if (FinalJsonTxt <> '') then begin
            exit(FinalJsonTxt);
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Web User Setup not found for user ' + UserID);
            exit(Myresult);
        end;
    END;

    //************************* ItemCategoryExport ********************************
    PROCEDURE ItemCategoryExport(): Text
    var
        ItemCategoryRec: Record "Item Category";
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        jsontext: Text;
        FinalJsonTxt: Text;
        Cnt: Integer;
        I: Integer;
        JsonObj: JsonObject;

    BEGIN
        ItemCategoryRec.RESET;
        ItemCategoryRec.SETFILTER(Description, '<>%1', '');
        ItemCategoryRec.SetFilter("Location Code", '<>%1', '');

        IF ItemCategoryRec.FINDFIRST THEN begin
            Cnt := ItemCategoryRec.Count;
            if Cnt > 1 then begin
                FinalJsonTxt := '[';
            end;
            repeat
                JsonObj.Add('No', ItemCategoryRec.Code);
                JsonObj.Add('Description', ItemCategoryRec.Description);
                JsonObj.WriteTo(jsontext);
                if (I >= 1) then begin
                    FinalJsonTxt += ',' + jsontext;
                end else begin
                    FinalJsonTxt += jsontext;
                end;
                jsontext := '';
                Clear(JsonObj);
                I += 1;
            until ItemCategoryRec.Next() = 0;

        end;
        if Cnt > 1 then begin
            FinalJsonTxt := FinalJsonTxt + ']';
        end;

        //EXIT(TRUE);
        if (FinalJsonTxt <> '') then begin
            exit(FinalJsonTxt);
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Item Category not found with  filter ' + ItemCategoryRec.GetFilters());
            exit(Myresult);
        end;
    end;

    //************************* GetNewNoSeriesOnlineSO ********************************
    PROCEDURE GetNewNoSeriesOnlineSO(inputJson: Text[2024]): Text[1024]
    VAR
        //Function In
        NoSeriesCode: Code[20];

        //Function Out
        NewNoSeriesCode: Code[30];
        Flg: Boolean;

        CodeNO: Code[20];
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        OnlineSOCode: Integer;
        Orderjson: JsonObject;
        Myresult: Text;
        input: JsonObject;
        c: JsonToken;

    BEGIN

        input.ReadFrom(inputJson);
        //Get NoSeriesCode
        if input.Get('NoSeriesCode', c) then begin
            NoSeriesCode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'NoSeriesCode Node not found in Payload');
            exit(Myresult);
        end;


        NoSeriesMgt.InitSeries(NoSeriesCode, NoSeriesCode, 0D, NewNoSeriesCode, CodeNO);
        //EXIT(TRUE);
        Orderjson.Add('id', '1');
        Orderjson.Add('Success', 'True');
        Orderjson.Add('Message', NewNoSeriesCode);
        Orderjson.WriteTo(Myresult);
        exit(Myresult);
    END;

    //************************* GetItemCategoryDetail ********************************
    PROCEDURE GetItemCategoryDetail(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        ItemCategoryCode: Code[20];
        //Function Out

        ItemCategoryDescription: Text[50];
        ItemCategoryLocationCode: Code[20];
        ItemCategoryBaseUnitofMeasure: Code[10];
        ErrorText: Text[100];
        Flg: Boolean;
        ItemCategoryRec: Record "Item Category";

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN

        input.ReadFrom(inputJson);
        //Get ItemCategoryCode
        if input.Get('ItemCategoryCode', c) then begin
            ItemCategoryCode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ItemCategoryCode Node not found in Payload');
            exit(Myresult);
        end;

        ItemCategoryRec.RESET;
        ItemCategoryRec.SETRANGE(Code, ItemCategoryCode);
        IF ItemCategoryRec.FINDFIRST THEN BEGIN
            ItemCategoryDescription := ItemCategoryRec.Description;
            ItemCategoryLocationCode := ItemCategoryRec."Location Code";
            ItemCategoryBaseUnitofMeasure := ItemCategoryRec."Base Unit of Measure";
            ErrorText := '';
            //EXIT(TRUE)
            Orderjson.Add('id', '1');
            Orderjson.Add('Success', 'True');
            Orderjson.Add('Message', '');
            Orderjson.Add('ItemCategoryDescription', ItemCategoryDescription);
            Orderjson.Add('ItemCategoryLocationCode', ItemCategoryLocationCode);
            Orderjson.Add('ItemCategoryBaseUnitofMeasure', ItemCategoryBaseUnitofMeasure);
            Orderjson.WriteTo(Myresult);
            exit(Myresult);



        END ELSE BEGIN
            ItemCategoryDescription := '';
            ItemCategoryLocationCode := '';
            ItemCategoryBaseUnitofMeasure := '';
            ErrorText := 'Item Category Code ' + ItemCategoryCode + ' Not found';
            //EXIT(FALSE);
            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('Message', '');
            Orderjson.Add('ItemCategoryDescription', ItemCategoryDescription);
            Orderjson.Add('ItemCategoryLocationCode', ItemCategoryLocationCode);
            Orderjson.Add('ItemCategoryBaseUnitofMeasure', ItemCategoryBaseUnitofMeasure);
            Orderjson.WriteTo(Myresult);
            exit(Myresult);

        END;
    END;

    //************************* GetItemCategoryUOM ********************************
    PROCEDURE GetItemCategoryUOM(inputJson: Text[1024]): Text[1024]
    var
        //Function In
        ItemCategoryCode: Code[20];
        //Function Out
        ItemCategoryUOM: Code[20];
        ItemCategoryRec: Record "Item Category";

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN

        input.ReadFrom(inputJson);
        //Get ItemCategoryCode
        if input.Get('ItemCategoryCode', c) then begin
            ItemCategoryCode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ItemCategoryCode Node not found in Payload');
            exit(Myresult);
        end;

        ItemCategoryRec.RESET;
        ItemCategoryRec.SETFILTER(Description, '<>%1', '');
        ItemCategoryRec.SETFILTER(Code, ItemCategoryCode);
        IF ItemCategoryRec.FINDFIRST THEN BEGIN
            ItemCategoryUOM := ItemCategoryRec."Base Unit of Measure";
            //EXIT(TRUE);
            Orderjson.Add('id', '1');
            Orderjson.Add('Success', 'True');
            Orderjson.Add('Message', '');
            Orderjson.Add('ItemCategoryUOM', ItemCategoryUOM);
            Orderjson.WriteTo(Myresult);
            exit(Myresult);


        END ELSE BEGIN
            ItemCategoryUOM := '';
            //EXIT(FALSE);
            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('Message', '');
            Orderjson.Add('ItemCategoryUOM', ItemCategoryUOM);
            Orderjson.WriteTo(Myresult);
            exit(Myresult);
        END;
    END;



    //************************* ItemCategoryApp ********************************
    PROCEDURE ItemCategoryApp(): Text
    var
        ItemCategoryAppRec: Record "Item Category App";
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        jsontext: Text;
        FinalJsonTxt: Text;
        Cnt: Integer;
        I: Integer;
        JsonObj: JsonObject;

    BEGIN
        ItemCategoryAppRec.RESET;
        ItemCategoryAppRec.SETFILTER("Catagory Code", '<>%1', '');
        ItemCategoryAppRec.SetFilter("Catagory Name", '<>%1', '');

        IF ItemCategoryAppRec.FINDFIRST THEN begin
            Cnt := ItemCategoryAppRec.Count;
            if Cnt > 1 then begin
                FinalJsonTxt := '[';
            end;
            repeat
                JsonObj.Add('catagory_code', ItemCategoryAppRec."Catagory Code");
                JsonObj.Add('catagory_Name', ItemCategoryAppRec."Catagory Name");
                JsonObj.Add('description', ItemCategoryAppRec.Description);
                JsonObj.Add('remark', ItemCategoryAppRec.Remark);

                JsonObj.WriteTo(jsontext);
                if (I >= 1) then begin
                    FinalJsonTxt += ',' + jsontext;
                end else begin
                    FinalJsonTxt += jsontext;
                end;
                jsontext := '';
                Clear(JsonObj);
                I += 1;
            until ItemCategoryAppRec.Next() = 0;

        end;
        if Cnt > 1 then begin
            FinalJsonTxt := FinalJsonTxt + ']';
        end;

        //EXIT(TRUE);
        if (FinalJsonTxt <> '') then begin
            exit(FinalJsonTxt);
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Data not found with filter ' + ItemCategoryAppRec.GetFilters());
            exit(Myresult);
        end;
    end;


    //************************* ItemExportLike ********************************
    PROCEDURE ItemExportLike(inputJson: Text[2024]): Text
    var
        ItemRec: Record "Item";
        ItemCateg: Code[30];
        ItemCode: Text;
        input: JsonObject;
        c: JsonToken;
        Myresult: Text;
        jsontext: Text;
        FinalJsonTxt: Text;
        Cnt: Integer;
        I: Integer;
        JsonObj: JsonObject;

    BEGIN

        input.ReadFrom(inputJson);
        //Get ItemCateg
        if input.Get('ItemCateg', c) then begin
            ItemCateg := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ItemCateg Node not found in Payload');
            exit(Myresult);
        end;
        //Get ItemCode
        if input.Get('ItemCode', c) then begin
            ItemCode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ItemCode Node not found in Payload');
            exit(Myresult);
        end;

        ItemRec.RESET;
        ItemRec.SETFILTER(Description, '<>%1', '');
        IF ItemCateg <> '' THEN
            ItemRec.SETFILTER("Item Category Code", ItemCateg);
        ItemRec.SETFILTER("No.", '%1', ItemCode + '*'); // Final
        IF ItemRec.FINDFIRST THEN begin
            Cnt := ItemRec.Count;
            if Cnt > 1 then begin
                FinalJsonTxt := '[';
            end;
            repeat
                JsonObj.Add('No', ItemRec."No.");
                JsonObj.Add('Description', ItemRec.Description);
                JsonObj.WriteTo(jsontext);
                if (I >= 1) then begin
                    FinalJsonTxt += ',' + jsontext;
                end else begin
                    FinalJsonTxt += jsontext;
                end;
                jsontext := '';
                Clear(JsonObj);
                I += 1;
            until ItemRec.Next() = 0;

        end;
        if Cnt > 1 then begin
            FinalJsonTxt := FinalJsonTxt + ']';
        end;

        //EXIT(TRUE);
        if (FinalJsonTxt <> '') then begin
            exit(FinalJsonTxt);
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Data not found with filter ' + ItemRec.GetFilters());
            exit(Myresult);
        end;
    end;


    PROCEDURE SaveSalesLine(inputJson: Text[2024]): Text
    var
        Item_No: Code[20];
        S: Code[10];
        M: Code[10];
        L: Code[10];
        XL: Code[10];
        XXL: Code[10];
        XXXL: Code[10];


        ItemRec: Record "Item";
        ItemCateg: Code[30];
        ItemCode: Text;
        input: JsonObject;
        c: JsonToken;
        Myresult: Text;
        jsontext: Text;
        FinalJsonTxt: Text;
        Cnt: Integer;
        I: Integer;
        JsonObj: JsonObject;
    BEGIN

        input.ReadFrom(inputJson);
        //Get Item_No
        if input.Get('Item_No', c) then begin
            Item_No := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Item_No Node not found in Payload');
            exit(Myresult);
        end;

        //Get Size S
        if input.Get('S', c) then begin
            S := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'S Node not found in Payload');
            exit(Myresult);
        end;
        //Get Size M
        if input.Get('M', c) then begin
            M := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'M Node not found in Payload');
            exit(Myresult);
        end;
        //Get Size L
        if input.Get('L', c) then begin
            L := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'L Node not found in Payload');
            exit(Myresult);
        end;

        //Get Size  XL
        if input.Get('XL', c) then begin
            XL := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'XL Node not found in Payload');
            exit(Myresult);
        end;

        //Get Size  XXL
        if input.Get('XXL', c) then begin
            XXL := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'XXL Node not found in Payload');
            exit(Myresult);
        end;

        //Get Size  XXXL
        if input.Get('XXXL', c) then begin
            XXXL := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'XXXL Node not found in Payload');
            exit(Myresult);
        end;

        if Not ItemRec.Get(Item_No) Then begin
            ItemRec.CalcFields(Inventory, "Net Change", "Qty. on Sales Order");


        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Item No. ' + Item_No + ' Not found in Item Master Table ');
            exit(Myresult);
        end;
    end;


    PROCEDURE ValidateItem(inputJson: Text[2024]): Text[1024]
    VAR
        //Function In
        ItemCategory: Code[20];
        ItemCode: Code[20];
        //Function Out
        ErroMsg: Text[250];
        ItemRec: Record "Item";
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN
        input.ReadFrom(inputJson);
        //Get ItemCategory
        if input.Get('ItemCategory', c) then begin
            ItemCategory := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ItemCategory Node not found in Payload');
            exit(Myresult);
        end;

        //Get ItemCode
        if input.Get('ItemCode', c) then begin
            ItemCode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ItemCode Node not found in Payload');
            exit(Myresult);
        end;


        ItemRec.RESET;
        ItemRec.SETRANGE(Blocked, FALSE);
        ItemRec.SETRANGE("No.", ItemCode);
        ItemRec.SETRANGE("Item Category Code", ItemCategory);
        IF ItemRec.FINDFIRST THEN BEGIN
            ErroMsg := '';
            //EXIT(TRUE);
            Myresult := CreateJsonPayload('1', 'True', ErroMsg);
            exit(Myresult);
        END ELSE BEGIN
            ErroMsg := 'Data Not Found Within Filter -' + ItemRec.GETFILTERS;
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErroMsg);
            exit(Myresult);
        END;
    END;



    PROCEDURE ValidateItemVariant(inputJson: Text[2024]): Text[1024]
    VAR
        //Function In
        ItemCode: Code[20];
        ItemVariantCode: Code[20];

        //Function Out
        ErroMsg: Text[250];
        ItemVariantRec: Record "Item Variant";
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN
        input.ReadFrom(inputJson);
        //Get ItemCode
        if input.Get('ItemCode', c) then begin
            ItemCode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ItemCode Node not found in Payload');
            exit(Myresult);
        end;

        //Get ItemVariantCode
        if input.Get('ItemVariantCode', c) then begin
            ItemVariantCode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ItemVariantCode Node not found in Payload');
            exit(Myresult);
        end;


        ItemVariantRec.RESET;
        ItemVariantRec.SETRANGE("Item No.", ItemCode);
        ItemVariantRec.SETRANGE(Code, ItemVariantCode);
        IF ItemVariantRec.FINDFIRST THEN BEGIN
            ErroMsg := '';
            //EXIT(TRUE);
            Myresult := CreateJsonPayload('1', 'True', ErroMsg);
            exit(Myresult);
        END ELSE BEGIN
            ErroMsg := 'Data Not Found Within Filter -' + ItemVariantRec.GETFILTERS;
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErroMsg);
            exit(Myresult);
        END;
    END;


    PROCEDURE UpdateUserIDInSaleOrderExport(inputJson: Text[2024]): Text[1024]
    VAR
        //Function In
        UserID: Code[100];
        DocuentNo: Code[30];

        //Function Out
        ErroMsg: Text[250];

        SaleOrderExportRec: Record SaleOrderExport;
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN
        input.ReadFrom(inputJson);

        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;

        //Get DocuentNo
        if input.Get('DocuentNo', c) then begin
            DocuentNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'DocuentNo Node not found in Payload');
            exit(Myresult);
        end;
        SaleOrderExportRec.RESET;
        SaleOrderExportRec.SETRANGE("Document No.", DocuentNo);
        IF SaleOrderExportRec.FINDFIRST THEN BEGIN
            repeat
                SaleOrderExportRec."User ID" := UserID;
                SaleOrderExportRec.Modify(True);
            until SaleOrderExportRec.Next() = 0;
            Myresult := CreateJsonPayload('1', 'True', ErroMsg);
            exit(Myresult);
        END ELSE BEGIN
            ErroMsg := 'Document No. Not Found Within Filter -' + SaleOrderExportRec.GETFILTERS;
            Myresult := CreateJsonPayload('0', 'False', ErroMsg);
            exit(Myresult);
        END;
    END;





}

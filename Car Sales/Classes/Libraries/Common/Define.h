//
//  Define.h
//  Saverpassport
//
//  Created by Nick LE on 10/9/12.
//  Copyright (c) 2012 Nick LE. All rights reserved.
//

#import "TextDefine.h"
#import "Strings.h"

#ifndef CarSales_Define_h
#define CarSales_Define_h

#define APP_NAME                @"中古車ナウ"
#define IMAGE_URL               @"http://"
#define URL_FILE_SQLITE         @"http://mobileteam.us.to/CarSaleDatabase.zip"

#define TIME_REDOWNLOAD         86400

//SQLITE

#define ALL_CAR_NUM_DB          @"all_car_num.db"
#define ALL_CAR_NUM_TB          @"all_car_num"
#define ALL_CAR_NUM_URL         @"http://usedcarget.net/master/all_car_num.db"

#define BODY_MASTER_DB          @"body_master.db"
#define BODY_MASTER_TB          @"body_master"
#define BODY_MASTER_URL         @"http://usedcarget.net/master/body_master.db"

#define CATALOG_MASTER_DB       @"catalog_master.db"
#define CATALOG_MASTER_TB       @"catalog_master"
#define CATALOG_MASTER_URL      @"http://usedcarget.net/master/catalog_master.db"

#define COLOR_MASTER_DB         @"color_master.db"
#define COLOR_MASTER_TB         @"color_master"
#define COLOR_MASTER_URL        @"http://usedcarget.net/master/color_master.db"

#define COMPANY_MASTER_DB       @"company_master.db"
#define COMPANY_MASTER_TB       @"company_master"
#define COMPANY_MASTER_URL      @"http://usedcarget.net/master/company_master.db"

#define PREF_MASTER_DB          @"pref_master.db"
#define PREF_MASTER_TB          @"pref_master"
#define PREF_MASTER_URL         @"http://usedcarget.net/master/pref_master.db"


// WEBSERVICE
#define WEB_URL                 @"http://www.carsensor.net/"
#define WS_PREF                 @"http://webservice.recruit.co.jp/carsensor/pref/v1/?key=b33beffa96b79c6e"

#define WS_MASTER               @"webapi/b/master/?"
#define WS_USEDCAR              @"webapi/b/p/usedcar/?"
#define WS_SHOP                 @"webapi/b/p/shop/?"

#define URL_VIEW_SHOP           @"https://www.carsensor.net/smph/ex_multi_inquiry_mm.php/?STID=smph201305071&vos=ncsralsa201206181se&%@=CU1914260934"

// new api
#define WEB_URL_2               @"http://webservice.recruit.co.jp/"
#define WS_USEDCAR_2            @"carsensor/usedcar/v1/?"
#define KEY_2                   @"key=b33beffa96b79c6e"

//PRAMETTERS

#define PRA_PN                  @"pn=gmotech"
#define PRA_KEY                 @"key=gmotech_2db37ca1"
#define PRA_ID                  @"id="
#define PRA_MAKER               @"maker="
#define PRA_SHASHU              @"shashu="
#define PRA_GRADE               @"grade="
#define PRA_KEYWORD             @"keyword="
#define PRA_PRICE_MIN           @"price_min="
#define PRA_PRICE_MAX           @"price_max="
#define PRA_TOTAL_PRICE         @"total_price="
#define PRA_ODD_MIN             @"odd_min="
#define PRA_ODD_MAX             @"odd_max="
#define PRA_YEAR_MIN            @"year_min="
#define PRA_YEAR_MAX            @"year_max="
#define PRA_SYAKEN              @"syaken="
#define PRA_COUNTRY             @"country="
#define PRA_PREF                @"pref="
#define PRA_COLOR               @"color="
#define PRA_BODY                @"body="
#define PRA_TYPE                @"type="
#define PRA_PRESON              @"person="
#define PRA_MISSON              @"mission="
#define PRA_REPAIR              @"repair="
#define PRA_NEW                 @"new="
#define PRA_COUPON              @"coupon="
#define PRA_SHOP_ID             @"shop_id="
#define PRA_ORDER               @"order="
#define PRA_COUNT               @"count="
#define PRA_PAGE                @"page="
#define PRA_NINTEI              @"nintei="
#define PRA_PLAN_EXT            @"plan_ext="
#define PRA_HCD                 @"hcd="
#define PRA_KOSHA_FLG           @"kosha_flg="
#define PRA_START               @"start="

#define PRA_SHOP_ID             @"shop_id="

#define PRA_MODE                @"mode="



//ERROR

#define ERROR_NO_INPUT          @"検索条件を入力してください。"
#define ERROR_NETWORK           @"ネットワークを検出できませんでした。通信状態を確認してください。"
#define ERROR_TIMEOUT           @"タイムアウトです。もう一度やり直してください。"


#endif

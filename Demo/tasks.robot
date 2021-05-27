# -*- coding: utf-8 -*-
*** Settings ***
Library           RPA.Browser.Selenium
Library           RPA.FileSystem
Library           RPA.Excel.Files
Library           RPA.Tables
Library           Collections
Resource          WebDataScraper.robot

# ****** The gioi di dong ***********
# ${url}            https://www.thegioididong.com/dtdd
# ${phone_path}     xpath://*[@id="categoryPage"]/div[3]/ul/li[*]/a/h3
# ${price_path}     xpath://*[@id="categoryPage"]/div[3]/ul/li[*]/a/strong
# ${load_more}      xpath://*[@id="categoryPage"]/div[3]/div[2]/a

*** Variables ***
#****** Viettel Store ***********
${url}            https://viettelstore.vn/dien-thoai
${phone_path}     xpath://*[@id="div_Danh_Sach_San_Pham"]/div[*]/a/h2
${price_path}     xpath://*[@id="div_Danh_Sach_San_Pham"]/div[*]/a/div[3]/span[1]
${load_more}      xpath://*[@id="div_Danh_Sach_San_Pham_loadMore_btn"]/a

${url}            https://memoryzone.com.vn/ram
${phone_path}     xpath://section/div/section/div[1]/div[*]/div/div[2]/h3[@class="product-name"]/a
${load_more}      xpath://a[.='Trang cuối']

${FILE_PATH}      ${CURDIR}${/}output.xlsx

*** Tasks ***
RunTask
    ${path_list}    Create List    ${phone_path}    #${price_path}
    ${headers_list}    Create List    Phone Name    #Price
    Open Link
    Create Excel File
    ${table}    Scrap Data To Table    ${path_list}    ${headers_list}    ${load_more}
    Write To Excel File    ${table}
    Log To Console    ...
    Log To Console    Done

*** Keywords ***
Open Link
    Open Chrome Browser    ${url}
    Wait Until Element Is Visible    ${load_more}
    Maximize Browser Window

Create Excel File
    ${file_exists}    Does File Exist    ${FILE_PATH}

    IF    ${file_exists} == True
        Remove File    ${FILE_PATH}
    END
    Create Workbook    ${FILE_PATH}
    Save Workbook

Write To Excel File
    [Arguments]    ${colum}
    Open Workbook    ${FILE_PATH}
    Append Rows To Worksheet    ${colum}    
    Save Workbook
    Close Workbook

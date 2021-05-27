*** Settings ***
Library           RPA.Browser.Selenium
Library           RPA.Tables
Library           Collections
Library           String

*** Keywords ***
Scrap Data To Table
    [Arguments]    ${elements_paths_list}    ${headers_list}    ${next_page_path}=${EMPTY}
    
    ${elements_data}    Scrap From Pages    ${elements_paths_list}    ${next_page_path}
    Insert Into List    ${elements_data}    0    ${headers_list}

    ${table}    Create Table    data=${elements_data}    columns=${headers_list}

    Set Table Row    ${table}    0    ${table.columns}

    [Return]    @{table}

Scrap From Pages
    [Arguments]    ${elements_paths_list}    ${next_page_path}=${EMPTY}

    ${elements_data_1}    Create List
    ${start_index}    ${step}    Get step    ${elements_paths_list}
    Log To Console    ${start_index} | ${step}

    # Read data first time
    ${elements_data_1}    ${max_item_per_page}    Read Data To List    ${elements_paths_list}    ${start_index}    ${step}
    
    FOR    ${i}    IN RANGE    1    999999    1
        ${elements_data_2}    Create List
        ${next}    Is Element Visible    ${next_page_path}
        Log To Console    page ${i} | ${next}
        Exit For Loop If    ${next} == False

        # Click next page
        Click Element    ${next_page_path}
        Sleep    1
        Wait Until Element Is Visible    ${elements_paths_list}[0] 
        
        # Read data 2
        ${start_index}    Evaluate    ${max_item_per_page}+1
        ${elements_data_2}    ${l_}    Read Data To List    ${elements_paths_list}    ${start_index}    ${step}
        IF    ${l_} == 0
            ${start_index}    Set Variable    1
            ${elements_data_2}    ${l_}    Read Data To List    ${elements_paths_list}    ${start_index}    ${step}
        ELSE
            ${max_item_per_page}    Set Variable    ${l_}
        END
        

        ${elements_data_1}    Combine Lists    ${elements_data_1}    ${elements_data_2}
    END    
    
    [Return]    ${elements_data_1}

Read Data To List
    [Arguments]    ${elements_paths}    ${start_index}=1    ${step}=1
    ${elements_count}    Get Length    ${elements_paths}
    ${elements_data}    Create List
    ${elements_data_temp}    Create List
    ${cur_index}    Set Variable    0
    
    FOR    ${i}    IN RANGE    ${start_index}    999999    ${step}
        ${paths}    Create List
        ${paths}    Copy List    ${elements_paths}
        ${elements}    Create List
        FOR    ${j}    IN RANGE    ${elements_count}
            ${elements_path_}    Replace String   ${elements_paths}[${j}]    [*]    [${i}]
            Set List Value    ${paths}    ${j}    ${elements_path_}
        END
        ${stillVisible}    Is Element Visible    ${paths}[0]
        Exit For Loop If    ${stillVisible} == False

        FOR    ${j}    IN RANGE    ${elements_count}
            ${is_visible}    Is Element Visible    ${paths}[${j}]
            IF    ${is_visible} == True
                ${content}    Get Element Attribute    ${paths}[${j}]    textContent
                Append To List    ${elements}    ${content.strip()}
            ELSE
                Append To List    ${elements}    ${EMPTY}
            END
            
        END
        Append To List    ${elements_data}    ${elements}
        ${cur_index}    Set Variable    ${i}
    END
    [Return]    ${elements_data}    ${cur_index}

Get step
    [Arguments]    ${elements_paths_list}
    ${start_index}    Set Variable
    ${step}    Set Variable
    ${elements}    Get WebElements    ${elements_paths_list}
    ${count_in_page}    Get Length    ${elements}
    FOR    ${i}    IN RANGE    ${count_in_page}
        ${elements_path_}    Replace String   ${elements_paths_list}[0]    [*]    [${i}]
        ${is_visible}    Is Element Visible    ${elements_path_}
        IF    ${is_visible} == True
            ${start_index}    Set Variable    ${i}
        END
        Exit For Loop If    ${is_visible} == True
    END

    FOR    ${i}    IN RANGE    ${start_index}+1    ${count_in_page}    1
        ${elements_path_}    Replace String   ${elements_paths_list}[0]    [*]    [${i}]
        ${is_visible}    Is Element Visible    ${elements_path_}
        IF    ${is_visible} == True
            ${step}    Evaluate    ${i}-${start_index}
        END
        Exit For Loop If    ${is_visible} == True
    END
    [Return]    ${start_index}    ${step}
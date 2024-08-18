*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}                       https://www.saucedemo.com/
${BROWSER}                   chrome
${USERNAME}                  standard_user
${PASSWORD}                  secret_sauce
${LOGIN_BUTTON}              xpath=//input[@type='submit']
${USERNAME_FIELD}            xpath=//input[@id='user-name']
${PASSWORD_FIELD}            xpath=//input[@id='password']
${PRODUCT_ADD_BUTTON}        xpath=//button[text()='Add to cart']
${PRODUCT_REMOVE_BUTTON}     xpath=//button[text()='Remove']
${CART_ICON}                 xpath=//a[@class='shopping_cart_link']
${CART_ITEM_COUNT}           xpath=//span[@class='shopping_cart_badge']
${CHECKOUT_BUTTON}           xpath=//button[@id='checkout']
${CHECKOUT_PAGE}             xpath=//input[@id='first-name']  # Primeiro campo da página de checkout para validar a navegação
${EXPECTED_TITLE}            Swag Labs
${EXPECTED_CART_COUNT}       1  # Número esperado de itens no carrinho
${EXPECTED_EMPTY_CART_COUNT}  0  # Número esperado de itens no carrinho após remoção


*** Test Cases ***
TC01 - Verificar se o usuário consegue fazer login com credenciais válidas
    [Setup]    Open Browser    ${URL}    ${BROWSER}
    [Teardown]    Close Browser
    Login With Valid Credentials
    Verify Redirection To Home Page

TC04 - Verificar a adição de Produto ao Carrinho
    [Setup]    Open Browser    ${URL}    ${BROWSER}
    [Teardown]    Close Browser
    Login With Valid Credentials
    Add Product To Cart
    Verify Product Added To Cart

TC05 - Verificar a Remoção de Produto do Carrinho
    [Setup]    Open Browser    ${URL}    ${BROWSER}
    [Teardown]    Close Browser
    Login With Valid Credentials
    Add Product To Cart
    Verify Product Added To Cart
    Remove Product From Cart
    Verify Product Removed From Cart

TC06 - Navegação para a Página de Checkout
    [Setup]    Open Browser    ${URL}    ${BROWSER}
    [Teardown]    Close Browser
    Login With Valid Credentials
    Add Product To Cart
    Navigate To Cart
    Proceed To Checkout
    Verify Checkout Page

TC07 - Preenchimento de Informações de Checkout
    [Setup]    Open Browser    ${URL}    ${BROWSER}
    [Teardown]    Close Browser
    Login With Valid Credentials
    Add Product To Cart
    Navigate To Cart
    Proceed To Checkout
    Fill Checkout Information
    Continue To Next Checkout Step
    Verify Payment Information Page

TC08 - Finalização da Compra com Sucesso
    [Setup]    Open Browser    ${URL}    ${BROWSER}
    [Teardown]    Close Browser
    Login With Valid Credentials
    Add Product To Cart
    Navigate To Cart
    Proceed To Checkout
    Fill Checkout Information
    Continue To Next Checkout Step
    Finish Purchase
    Verify Checkout Complete Page

TC09 - Redirecionamento para a Página Principal Após Finalização da Compra
    [Setup]    Open Browser    ${URL}    ${BROWSER}
    [Teardown]    Close Browser
    Login With Valid Credentials
    Add Product To Cart
    Navigate To Cart
    Proceed To Checkout
    Fill Checkout Information
    Continue To Next Checkout Step
    Finish Purchase
    Verify Checkout Complete Page
    Go Back To Home Page

TC10 - Verificar se o usuário consegue fazer logout
    [Setup]    Open Browser    ${URL}    ${BROWSER}
    [Teardown]    Close Browser
    Login With Valid Credentials
    Logout
    Verify Logout

*** Keywords ***
Login With Valid Credentials
    Input Text    ${USERNAME_FIELD}    ${USERNAME}
    Input Text    ${PASSWORD_FIELD}    ${PASSWORD}
    Click Button  ${LOGIN_BUTTON}

Verify Redirection To Home Page
    Title Should Be    ${EXPECTED_TITLE}

Add Product To Cart
    Click Button    ${PRODUCT_ADD_BUTTON}
    Wait Until Element Is Visible    ${CART_ITEM_COUNT}    timeout=10s

Remove Product From Cart
    Wait Until Element Is Visible    ${CART_ICON}    timeout=10s
    Click Button    ${PRODUCT_REMOVE_BUTTON}

Verify Product Added To Cart
    Wait Until Element Is Visible    ${CART_ITEM_COUNT}    timeout=10s
    ${cart_item_count}=    Get Text    ${CART_ITEM_COUNT}
    Should Be Equal As Strings    ${cart_item_count}    ${EXPECTED_CART_COUNT}

Verify Product Removed From Cart
    Wait Until Element Is Not Visible    ${CART_ITEM_COUNT}    timeout=10s
    ${cart_item_count}=    Run Keyword And Return Status    Get Text    ${CART_ITEM_COUNT}
    Run Keyword If    '${cart_item_count}' == ''    Should Be Equal As Strings    ${cart_item_count}    ${EXPECTED_EMPTY_CART_COUNT}

Navigate To Cart
    Click Link    ${CART_ICON}

Proceed To Checkout
    Wait Until Element Is Visible    ${CHECKOUT_BUTTON}    timeout=10s
    Wait Until Element Is Enabled    ${CHECKOUT_BUTTON}    timeout=10s
    Click Button    ${CHECKOUT_BUTTON}

Verify Checkout Page
    Wait Until Element Is Visible    ${CHECKOUT_PAGE}    timeout=10s

Fill Checkout Information
    Input Text    xpath=//input[@id='first-name']    Inara
    Input Text    xpath=//input[@id='last-name']     Souza
    Input Text    xpath=//input[@id='postal-code']   13058016

Continue To Next Checkout Step
    Click Button    xpath=//input[@id='continue']

Verify Payment Information Page
    Wait Until Element Is Visible    xpath=//div[@class='summary_info']    timeout=10s

Finish Purchase
    Click Button    xpath=//button[@id='finish']

Verify Checkout Complete Page
    ${completion_message_part1}=    Get Text    xpath=//h2[contains(text(), 'Thank you for your order!')]
    ${completion_message_part2}=    Get Text    xpath=//div[@class='complete-text']
    ${back_home_button}=    Get Element Attribute    xpath=//button[@id='back-to-products']    class
    Should Contain    ${completion_message_part1}    Thank you for your order!
    Should Contain    ${completion_message_part2}    Your order has been dispatched, and will arrive just as fast as the pony can get there!
    Should Contain    ${back_home_button}    btn_primary

Go Back To Home Page
    Click Button    xpath=//button[@id='back-to-products']

Logout
    Click Button    xpath=//button[@id='react-burger-menu-btn']
    Wait Until Element Is Visible    xpath=//a[@id='logout_sidebar_link']    timeout=10s
    Click Link    xpath=//a[@id='logout_sidebar_link']

Verify Logout
    # Aguarda até que a URL da página de login seja a esperada
    Wait Until Page Contains    ${EXPECTED_TITLE}    timeout=10s
    Location Should Be    ${URL}

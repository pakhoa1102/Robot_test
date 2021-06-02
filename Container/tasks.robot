*** Settings ***
Documentation   Template robot main suite.
Library    RPA.Browser.Selenium

*** Tasks ***
Chrome Headless Test
    Open Available Browser    https://www.google.com/
    Screenshot    filename=google.png

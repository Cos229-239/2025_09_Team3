Flutter Setup

    You will need to set up flutter so that it knows where the SDK is stored.
    We have included the flutter SDK in this repository, so all you should need to do is specify the path.
    First, press windows + S. Type 'environment variables', and select 'Edit the system environment variables'.
    From there, click 'Environment Variables'. Navigate to 'System Variables', and find 'Path'.
    Click 'Edit', then 'New'.
    Finally, add the file path of the flutter\bin folder, and the location of your Android SDK.
    The location will vary by system, but the android SDK typically stored under 'C:\Users\<username>\AppData\Local\Android\Sdk\platform-tools'.
    The flutter folder will be stored in your local repository.
    Once you've done that, click 'OK' to save, and your IDE or other programs.

    To verify that this was successful, open a terminal and run 'flutter doctor'.
## Screener.in Notebook Highlighter with Tampermonkey

Features of the script:

    1) This script automatically opens the Notebook on a stock page at screener.in, checks if you’ve marked the stock with a "NO" in your notes, and turns the entire page red if found — helping avoid re-analysis of rejected stocks.

    2) This script checks for pledged percentage and colors dark red if pledged shares % > 0


### 🛠️ Step 1: Install Tampermonkey
Go to https://tampermonkey.net

Install the extension for your browser:

Chrome / Brave / Edge → Click "Download"

Firefox / Safari also supported

### 📝 Step 2: Create a New Script
Click the Tampermonkey extension icon

Select “Create a new script”

Remove all default content

### 🧾 Step 3: Paste the Script
Paste the following script inside the editor:


    Open file screener_script.txt and copy paste it's content

### 💾 Step 4: Save the Script
Click File → Save or use the 💾 Save button

Close the editor

### 🚀 Step 5: Try It Out
Visit any stock page on Screener, e.g.
👉 https://www.screener.in/company/NAGAFERT/

Make sure you have some Notebook content saved

If the note contains "NO" (capital), the background turns red instantly! 🔴

✅ Output Example
Notebook Text	Page Turns Red?
NO	✅ Yes
Rejected	❌ No
no	✅ Yes (case-insensitive)
Buy Later	❌ No
🧰 Optional Upgrades
Highlight notes with "YES" or "BUY" in green 🟢

Add icons or banners on the page

Collapse notes after checking

Let me know if you want help with any of those! Happy filtering, and no more wasting time on your "NO" stocks 😄📉📕
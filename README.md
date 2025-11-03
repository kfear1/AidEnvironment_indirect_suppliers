Indirect suppliers project

Overview

Identifying new indirect suppliers from GTA data, produces shapefiles that contain indirect supplier farms. Project uses Python, R, and QGIS


Project Structure

indirect_suppliers/
├── data/             # New indirect suppliers polygons
├── scripts/          # Python and R scripts
├── outputs/          # Excel results summary and maps
├── README.md         # This file
├── requirements.txt  # File containing python requirements


Installation

List dependencies and how to install them.

# Create a virtual environment (optional)
python -m venv venv
source venv/bin/activate  # On Windows use: venv\Scripts\activate

# Install requirements for Python
pip install -r requirements.txt


Usage

To run the scripts, it is best to open them in a code editor like Visual Studio Code or R studio, enter file paths at the top, adjust the function call at the bottom if necessary, and run the script. Comments on each script will walk you through this process.

The order to use the scripts is:

1st cleaning: cleaning_sigef.R, GTA_cleaning.R

2nd separating files into each state: separate_by_state.py

3rd joining: all_states_join.py

4th QGIS manipulation (in QGIS) to calculate difference between old files and new: name the resulting files as Difference_state_company_ SIGEF or SNCI, and also remove any residual polygons that are unhelpful (e.g small lines-- can remove by using the field calculator to create an area column, and remove rows with very small areas)

5th joining with the direct files to get final destination information: 
    1st clean the files: clean_indirect_and_direct.py
    2nd join them:  add_final_mun.py


Author info

Katie Fear
GitHub Profile: kfear1
Contact info: krfear@hotmail.co.uk



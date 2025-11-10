import pandas as pandas
import numpy as np

ad2_m_mri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNI2/010_ADNI2_M_MRI_8_02_2021.csv')
ad2_m_fmri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNI2/012_ADNI2_M_fMRI_8_04_2021.csv')
ad2_f_mri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNI2/009_ADNI2_F_MRI_8_02_2021.csv')
ad2_f_fmri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNI2/011_ADNI2_F_fMRI_8_04_2021.csv')

ad3_m_mri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNI3/ADNI3_MRI_M_8_06_2021.csv')
ad3_m_fmri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNI3/ADNI3_fMRI_M_8_06_2021.csv')
ad3_f_mri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNI3/ADNI3_MRI_F_8_06_2021.csv')
ad3_f_fmri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNI3/ADNI3_fMRI_F_8_06_2021.csv')

adgo_m_mri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNIGO/002_GO_M_MRI_8_02_2021.csv')
adgo_m_fmri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNIGO/006_GO_M_fMRI_8_02_2021.csv')
adgo_f_mri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNIGO/001_GO_F_MRI_8_02_2021.csv')
adgo_f_fmri = pd.read_csv('/N/project/statadni/20231212_ADR012021_UtahBackup/ImagingData/dicomImages/ADNIGO/005_GO_F_fMRI_8_02_2021.csv')

ad2_m = pd.merge(ad2_m_mri, ad2_m_fmri, how='outer')
ad2_f = pd.merge(ad2_f_mri, ad2_f_fmri, how='outer')
ad2 = pd.merge(ad2_m, ad2_f, how='outer')
ad3_m = pd.merge(ad3_m_mri, ad3_m_fmri, how='outer')
ad3_f = pd.merge(ad3_f_mri, ad3_f_fmri, how='outer')
ad3 = pd.merge(ad3_m, ad3_f, how='outer')
adgo_m = pd.merge(adgo_m_mri, adgo_m_fmri, how='outer')
adgo_f = pd.merge(adgo_f_mri, adgo_f_fmri, how='outer')
adgo = pd.merge(adgo_m, adgo_f, how='outer')
ad23 = pd.merge(ad2, ad3, how='outer')
all_data = pd.merge(ad23, adgo, how='outer')


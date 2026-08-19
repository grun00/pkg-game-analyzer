import { useTranslation } from "react-i18next";

export default function CreatorDashboard() {
  const { t } = useTranslation("common");

  return (
    <>
      <div className="page-hd">
        <h1 className="page-title">{t("creator.title")}</h1>
      </div>
      <div className="empty">
        <p>{t("creator.comingSoon")}</p>
      </div>
    </>
  );
}

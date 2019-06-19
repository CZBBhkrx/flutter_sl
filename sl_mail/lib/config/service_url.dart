const serviceUrl = "http://baixingliangfan.cn/baixing/";

const HOMEPAGE_CONTENT = 'homePageContent'; //商店首页信息
const HOMEPAGE_BELOW_CONTENT = 'homePageBelowContent'; //商城首页热卖商品拉取
const GET_CATEGORY="getCategory";
const servicePath = {
  HOMEPAGE_CONTENT: serviceUrl + 'bxAppIndex/getHomePageContent',
  HOMEPAGE_BELOW_CONTENT: serviceUrl + "wxmini/homePageBelowConten",
  GET_CATEGORY: serviceUrl+'wxmini/getCategory',
};

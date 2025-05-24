import { appTasks, OhosAppContext, OhosPluginId  } from '@ohos/hvigor-ohos-plugin';
import { hvigor, getNode, FileUtil } from '@ohos/hvigor'

//https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-hvigor-config-ohos-sample-V5#section67131365449
// 获取根节点
const rootNode = getNode(__filename);
// 为根节点添加一个afterNodeEvaluate hook 在hook中修改根目录下的build-profile.json5的内容并使能
rootNode.afterNodeEvaluate(node => {
    // 获取app插件的上下文对象
    const appContext = node.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
    const propertiesPath = FileUtil.pathResolve(appContext.getProjectPath(), "build-properties.json5")
    if (!FileUtil.exist(propertiesPath)) {
        throw new Error("build-properties.json5 not found.")
    }
    const properties = FileUtil.readJson5(propertiesPath)

    // 通过上下文对象获取从根目录build-profile.json5文件中读出来的obj对象
    const buildProfileOpt = appContext.getBuildProfileOpt();
    // 修改obj对象为想要的，此处举例修改app中的signingConfigs
    buildProfileOpt['app']['signingConfigs'] = properties.signingConfigs;
    // 将obj对象设置回上下文对象以使能到构建的过程与结果中
    appContext.setBuildProfileOpt(buildProfileOpt);
})

export default {
    system: appTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[]         /* Custom plugin to extend the functionality of Hvigor. */
}
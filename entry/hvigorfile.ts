import { hapTasks, OhosHapContext, OhosPluginId, Target } from '@ohos/hvigor-ohos-plugin';
import { hvigor, HvigorNode, HvigorPlugin } from '@ohos/hvigor';

export function dynamicDependencyPlugin(): HvigorPlugin {
    return {
        pluginId: 'dynamicDependencyPlugin',
        async apply(currentNode: HvigorNode): Promise<void> {
            const hapContext = currentNode.getContext(OhosPluginId.OHOS_HAP_PLUGIN) as OhosHapContext;
            hapContext?.targets((target: Target) => {
                const targetName = target.getTargetName();
                const dependency = hapContext.getDependenciesOpt();
                if (targetName === 'system') {
                    dependency['@ohpg/system'] = '@param:ohpg';
                } else if (targetName === 'default') {
                    dependency['@ohpg/mpv'] = '@param:ohpg';
                }
                hapContext.setDependenciesOpt(dependency)
            });
        }
    };
}
export default {
    system: hapTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[
        /* Custom plugin to extend the functionality of Hvigor. */
        dynamicDependencyPlugin()
    ]
}

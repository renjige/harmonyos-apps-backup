import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { FactItem, SceneChip } from '../../models/CommonSenseModels'
import { CommonSenseBizService } from '../../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../../services/CommonSenseDetailNav'

@Component
export struct SceneGuideDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop sceneKey: string = 'tips'
  @State facts: FactItem[] = []
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await CommonSenseBizService.loadFacts()
    this.facts = CommonSenseBizService.filterByScene(all, this.sceneKey)
    this.loaded = true
  }

  private cover(): Resource {
    if (this.sceneKey === 'foodsave') {
      return $r('app.media.cover_food')
    }
    if (this.sceneKey === 'travel') {
      return $r('app.media.cover_nature')
    }
    if (this.sceneKey === 'emergency') {
      return $r('app.media.cover_health')
    }
    if (this.sceneKey === 'clean') {
      return $r('app.media.cover_life')
    }
    return $r('app.media.cover_life')
  }

  private guideBody(): string {
    if (this.sceneKey === 'clean') {
      return '居家清洁先认材质再选试剂。油烟机滤网、冰箱封条、大理石台面各有做法，点下面条目可收藏、加入清单或去做问答。'
    }
    if (this.sceneKey === 'foodsave') {
      return '食材保存看水分和温度。叶菜擦干再装袋、鸡蛋临做再洗，能减少腐败和交叉污染。'
    }
    if (this.sceneKey === 'travel') {
      return '出行安全的核心是被看见、保持清醒。夜骑灯光、长途停车休息，都是马上能做的动作。'
    }
    if (this.sceneKey === 'emergency') {
      return '家庭应急先停损再求助：漏电保护器月测、燃气先关阀通风、烫伤冲凉水。不替代 120 / 119。'
    }
    return '生活小窍门把重复动作变成固定位置和固定顺序，减少找东西和临时决策。'
  }

  build() {
    DetailShell({
      title: SceneChip.labelOf(this.sceneKey),
      onClose: (): void => { CommonSenseDetailNav.close() }
    }) {
      if (!this.loaded) {
        AppEmpty({ title: '正在加载场景指南', description: '请稍候' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(this.cover())
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(10,37,64,0)', 0.3], ['rgba(10,37,64,0.8)', 1]]
                })
              Text(SceneChip.labelOf(this.sceneKey))
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F5F7FA')
                .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text(this.guideBody())
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column({ space: Theme.space.s3 }) {
              AppButton({
                label: '去做相关问答',
                onTap: (): void => { CommonSenseDetailNav.openQuiz() }
              })
              AppButton({
                label: '打开场景条目列表',
                variant: 'secondary',
                onTap: (): void => { CommonSenseDetailNav.openScenes() }
              })
              ForEach(this.facts, (row: FactItem) => {
                Text(row.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().brandPrimary)
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.card)
                  .onClick((): void => { CommonSenseDetailNav.openFact(row.id) })
              }, (row: FactItem) => row.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
  }
}

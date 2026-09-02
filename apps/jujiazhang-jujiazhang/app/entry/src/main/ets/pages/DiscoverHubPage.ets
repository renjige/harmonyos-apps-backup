import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { ChoiceChip } from '../components/family/ChoiceChip'
import { LifeSceneDef } from '../models/LifeSceneModels'
import { KnowledgeArticle } from '../models/JujiaModels'
import { ScenePackService } from '../services/ScenePackService'
import { KnowledgeService } from '../services/KnowledgeService'
import { FamilyOrderService } from '../services/FamilyOrderService'
import { SceneDetailPane } from '../components/detail/SceneDetailPane'
import { GuideDetailPane } from '../components/detail/GuideDetailPane'

@Component
export struct DiscoverHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State segment: string = 'scene'
  @State scenes: LifeSceneDef[] = []
  @State articles: KnowledgeArticle[] = []
  @State orderScore: number = 0
  @State showSceneDetail: boolean = false
  @State sceneDetail: LifeSceneDef = new LifeSceneDef()
  @State showGuideDetail: boolean = false
  @State guideDetail: KnowledgeArticle = new KnowledgeArticle()
  @Prop embedded: boolean = false
  @Prop @Watch('onRefresh') refreshToken: number = 0
  onClose: () => void = () => {}
  onApplyScene: (code: string) => void = (_c: string) => {}

  aboutToAppear(): void {
    this.reloadData()
  }

  onRefresh(): void {
    this.reloadData()
  }

  private reloadData(): void {
    this.scenes = ScenePackService.catalog()
    this.articles = KnowledgeService.articles()
    this.orderScore = FamilyOrderService.score()
  }

  private openScene(scene: LifeSceneDef): void {
    this.sceneDetail = scene
    this.showSceneDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeSceneDetail(): void {
    this.showSceneDetail = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private applyCurrentScene(): void {
    this.onApplyScene(this.sceneDetail.code)
    this.closeSceneDetail()
  }

  private openGuide(art: KnowledgeArticle): void {
    this.guideDetail = art
    this.showGuideDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeGuideDetail(): void {
    this.showGuideDetail = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  build() {
    Stack() {
      Column() {
        if (this.embedded) {
          Column({ space: 6 }) {
            Text('生活发现')
              .fontSize(Theme.type.titleM)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text('8 大生活场景 · 居家指南 · 维护模板 · 家庭手册')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Row({ space: 8 }) {
              this.StatPill(`${this.orderScore}`, '有序指数')
              this.StatPill(`${this.scenes.length}`, '场景包')
              this.StatPill(`${this.articles.length}`, '指南')
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: 8 })
        } else {
          Row({ space: 8 }) {
            AppIcon({ name: 'chevron', iconSize: 18, color: Theme.colors().textSecondary })
              .rotate({ angle: 180 })
            Text('生活发现')
              .fontSize(Theme.type.titleM)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text(`${this.orderScore} 分`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: 8 })
          .onClick(() => this.onClose())

          Text(FamilyOrderService.moduleHint())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        }

        Scroll() {
          Row({ space: 8 }) {
            ChoiceChip({ label: '生活场景', active: this.segment === 'scene', onPick: () => { this.segment = 'scene' } })
            ChoiceChip({ label: '居家指南', active: this.segment === 'guide', onPick: () => { this.segment = 'guide' } })
            ChoiceChip({ label: '维护模板', active: this.segment === 'maint', onPick: () => { this.segment = 'maint' } })
            ChoiceChip({ label: '家庭手册', active: this.segment === 'playbook', onPick: () => { this.segment = 'playbook' } })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        Scroll() {
          Column({ space: 10 }) {
            if (this.segment === 'scene') {
              ForEach(this.scenes, (scene: LifeSceneDef) => {
                Column({ space: 6 }) {
                  Text(scene.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(scene.subtitle)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  Row({ space: 6 }) {
                    Text('查看详情')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                    AppIcon({ name: 'chevron', iconSize: 14, color: Theme.colors().brandPrimary })
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(14)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick(() => this.openScene(scene))
              }, (scene: LifeSceneDef) => scene.code)
            }
            if (this.segment === 'guide') {
              ForEach(this.articles, (art: KnowledgeArticle) => {
                Column({ space: 4 }) {
                  Text(art.category)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                  Text(art.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(art.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  Text('阅读全文 ›')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                    .margin({ top: 4 })
                }
                .width('100%')
                .padding(14)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick(() => this.openGuide(art))
              }, (art: KnowledgeArticle) => art.id)
            }
            if (this.segment === 'maint') {
              this.MaintRow('空调滤网', '每 1–3 月清洗，可登记物品并设维护提醒')
              this.MaintRow('净水器滤芯', '按说明书更换，到期前 7 天提醒')
              this.MaintRow('烟雾报警器', '每月测试一次，每年更换电池')
              this.MaintRow('燃气安全', '软管老化检查，配合维修备忘记录')
            }
            if (this.segment === 'playbook') {
              this.PlaybookRow('物品台账', '登记家电、证件、药品，到期提醒与维护记录')
              this.PlaybookRow('家庭计划', '待办、重复事项与月历视图，配合提醒准时完成')
              this.PlaybookRow('备忘与清单', '购物、旅行、装修清单，勾选进度一目了然')
              this.PlaybookRow('生活日记', '记录家庭片段，配合成长统计与周报告回顾')
              this.PlaybookRow('搜索与收藏', '跨模块检索计划、物品与备忘，常用内容一键收藏')
              this.PlaybookRow('家人协作', '轮值盖章、成员管理与家庭目标，共同维护有序之家')
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.showSceneDetail) {
        SceneDetailPane({
          scene: this.sceneDetail,
          onClose: (): void => { this.closeSceneDetail() },
          onApply: (): void => { this.applyCurrentScene() }
        })
          .width('100%')
          .height('100%')
          .zIndex(30)
      }

      if (this.showGuideDetail) {
        GuideDetailPane({
          article: this.guideDetail,
          onClose: (): void => { this.closeGuideDetail() }
        })
          .width('100%')
          .height('100%')
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatPill(value: string, label: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(10)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MaintRow(title: string, body: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(body)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  PlaybookRow(title: string, body: string) {
    Column({ space: 4 }) {
      Row({ space: 6 }) {
        AppIcon({ name: 'check', iconSize: 16, color: Theme.colors().brandPrimary })
        Text(title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      Text(body)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}

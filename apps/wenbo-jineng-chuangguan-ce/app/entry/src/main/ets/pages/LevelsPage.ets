import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LevelListCard } from '../components/skill/SkillCards'
import { SkillCategory, SkillLevel } from '../models/SkillModels'
import { SkillBizService } from '../services/SkillBizService'
import { SkillNav } from '../services/SkillNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct LevelsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State categories: SkillCategory[] = []
  @State levels: SkillLevel[] = []
  @State selectedCat: string = ''
  @State loading: boolean = true
  @StorageLink('skillTick') tick: number = 0

  aboutToAppear(): void {
    void this.boot()
  }

  async boot(): Promise<void> {
    this.loading = true
    this.categories = await SkillBizService.loadCategories()
    if (this.categories.length > 0 && this.selectedCat.length === 0) {
      this.selectedCat = this.categories[0].category.length > 0 ?
        this.categories[0].category : this.categories[0].id
    }
    await this.reloadLevels()
    this.loading = false
  }

  async reloadLevels(): Promise<void> {
    this.levels = await SkillBizService.loadLevelsByCategory(this.selectedCat)
  }

  private selectCategory(cat: string): void {
    this.selectedCat = cat
    void this.reloadLevels()
  }

  private meta(lv: SkillLevel): string {
    const stars = SkillBizService.difficultyStars(lv)
    const dur = `${lv.durationMin}分钟 · +${lv.growthValue}成长`
    if (ProgressStore.isCompleted(lv.id)) {
      return `${stars} · 已通关`
    }
    if (!ProgressStore.isUnlocked(lv.id, lv.prerequisiteId)) {
      return `${stars} · 未解锁`
    }
    return `${stars} · ${dur}`
  }

  build() {
    Column() {
      Text('关卡')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })
      Text('按技能领域筛选，完成前置关卡解锁下一关')
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.categories.length > 0) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.categories, (cat: SkillCategory) => {
              Text(cat.title)
                .fontSize(13)
                .fontColor(this.selectedCat === cat.category || this.selectedCat === cat.id ?
                  Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.selectedCat === cat.category || this.selectedCat === cat.id ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick(() => this.selectCategory(cat.category.length > 0 ? cat.category : cat.id))
            }, (cat: SkillCategory) => cat.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .margin({ bottom: Theme.space.s3 })
      }

      if (this.loading) {
        AppEmpty({ title: '加载中', description: '正在获取关卡列表…' })
      } else if (this.levels.length === 0) {
        AppEmpty({
          title: '暂无关卡',
          description: SkillBizService.lastHint(),
          actionLabel: '刷新',
          onAction: () => { void this.boot() }
        })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.levels, (lv: SkillLevel) => {
              LevelListCard({
                title: lv.title,
                summary: lv.summary,
                meta: this.meta(lv),
                coverKey: lv.coverKey.length > 0 ? lv.coverKey : 'hero_bg',
                locked: !ProgressStore.isUnlocked(lv.id, lv.prerequisiteId),
                completed: ProgressStore.isCompleted(lv.id),
                onTap: () => SkillNav.openLevel(lv.id)
              })
            }, (lv: SkillLevel) => lv.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}

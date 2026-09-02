import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CourseItem, KpiItem, TeacherItem, ArticleItem, ActivityItem } from '../../models/CareerModels'
import { CareerMedia } from '../../services/CareerMedia'

export class QuickEntryItem {
  label: string = ''
  sub: string = ''
  icon: string = 'chart'
  action: string = ''

  static defaults(): QuickEntryItem[] {
    const out: QuickEntryItem[] = []
    const a = new QuickEntryItem()
    a.label = '我的学习'
    a.sub = '进度追踪'
    a.icon = 'chart'
    a.action = 'learn'
    out.push(a)
    const b = new QuickEntryItem()
    b.label = '智慧诊断'
    b.sub = '职业问卷'
    b.icon = 'ai'
    b.action = 'wisdom'
    out.push(b)
    const c = new QuickEntryItem()
    c.label = '我的收藏'
    c.sub = '课程清单'
    c.icon = 'message'
    c.action = 'fav'
    out.push(c)
    const d = new QuickEntryItem()
    d.label = '全部课程'
    d.sub = '免费畅学'
    d.icon = 'biz'
    d.action = 'catalog'
    out.push(d)
    return out
  }
}

export class CategoryTileItem {
  label: string = ''
  key: string = ''
  coverKey: string = ''

  static career(): CategoryTileItem[] {
    const mk = (label: string, key: string, coverKey: string): CategoryTileItem => {
      const t = new CategoryTileItem()
      t.label = label
      t.key = key
      t.coverKey = coverKey
      return t
    }
    return [
      mk('职场技能', '职场技能', 'cover_skill'),
      mk('管理能力', '管理能力', 'cover_manage'),
      mk('沟通表达', '沟通表达', 'cover_comm'),
      mk('职业规划', '职业规划', 'cover_plan'),
    ]
  }
}

@Component
export struct CareerHeroBanner {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '职业课堂'
  @Prop tagline: string = ''
  @Prop company: string = ''
  onSearch: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(CareerMedia.hero())
        .width('100%')
        .height(248)
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height(248)
        .linearGradient({
          angle: 180,
          colors: [[0x00000000, 0.0], [0xCC0F1638, 0.55], [0xF01A2A6C, 1.0]]
        })
      Column({ space: Theme.space.s3 }) {
        Row({ space: Theme.space.s2 }) {
          Column({ space: 2 }) {
            Text(this.appName)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(this.tagline)
              .fontSize(Theme.type.subhead)
              .fontColor('#FFFFFF')
              .maxLines(2)
              .opacity(1)
            Text(this.company)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Column() {
            Text('免费')
              .fontSize(Theme.type.caption)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandDeep)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(Theme.colors().brandAccent)
              .borderRadius(Theme.radius.pill)
          }
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: '#FFFFFF' })
          Text('搜索课程、讲师、职场资讯')
            .fontSize(Theme.type.subhead)
            .fontColor('rgba(255,255,255,0.85)')
            .layoutWeight(1)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: '#FFFFFF' })
        }
        .width('100%')
        .height(44)
        .padding({ left: Theme.space.s4, right: Theme.space.s4 })
        .backgroundColor('rgba(255,255,255,0.14)')
        .borderRadius(Theme.radius.pill)
        .border({ width: 1, color: 'rgba(255,255,255,0.22)' })
        .onClick(() => this.onSearch())
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s5,
        top: Theme.space.s6
      })
      .width('100%')
    }
    .width('100%')
    .height(248)
    .borderRadius(Theme.radius.xl)
    .clip(true)
    .shadow({
      radius: 24,
      color: 'rgba(26,42,108,0.18)',
      offsetY: 8,
      offsetX: 0
    })
  }
}

@Component
export struct CareerKpiStrip {
  @Prop kpis: KpiItem[] = []
  @Prop courseCount: number = 0
  @Prop teacherCount: number = 0

  private val(key: string, fb: string): string {
    for (let k of this.kpis) {
      if (k.key === key) return `${k.value}`
    }
    return fb
  }

  build() {
    Row({ space: Theme.space.s2 }) {
      this.KpiCell('精品课程', this.val('courses', `${this.courseCount}`), '持续更新')
      this.KpiCell('资深讲师', this.val('teachers', `${this.teacherCount}`), '实战背景')
      this.KpiCell('累计学习', this.val('learners', '1.2万+'), '职场同行')
    }
    .width('100%')
  }

  @Builder
  KpiCell(label: string, value: string, hint: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .fontWeight(FontWeight.Medium)
      Text(hint)
        .fontSize(Theme.type.overline)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}

@Component
export struct CareerQuickGrid {
  @Prop entries: QuickEntryItem[] = QuickEntryItem.defaults()
  onTap: (action: string) => void = (_a: string) => {}

  build() {
    GridRow({ columns: 4, gutter: Theme.space.s2 }) {
      ForEach(this.entries, (e: QuickEntryItem) => {
        GridCol() {
          Column({ space: 6 }) {
            Column() {
              AppIcon({
                name: e.icon === 'chart' ? 'chart' :
                  e.icon === 'ai' ? 'ai' :
                    e.icon === 'message' ? 'message' : 'biz',
                iconSize: Theme.icon.lg,
                color: Theme.colors().brandPrimary
              })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.md)
            Text(e.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .fontWeight(FontWeight.Medium)
            Text(e.sub)
              .fontSize(Theme.type.overline)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
          .onClick(() => this.onTap(e.action))
        }
      }, (e: QuickEntryItem) => e.action)
    }
    .width('100%')
  }
}

@Component
export struct CareerWisdomBanner {
  onTap: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Image($r('app.media.banner_wisdom'))
        .width('100%')
        .height(112)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
      Column()
        .width('100%')
        .height(112)
        .borderRadius(Theme.radius.md)
        .linearGradient({
          angle: 90,
          colors: [[0xE61A2A6C, 0.0], [0x991A2A6C, 0.55], [0x00000000, 1.0]]
        })
      Row({ space: Theme.space.s3 }) {
        Column({ space: 4 }) {
          Text('智慧学习助手')
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('职业倾向问卷 · 生成专属学习路径建议')
            .fontSize(Theme.type.caption)
            .fontColor('rgba(255,255,255,0.92)')
            .maxLines(2)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: Theme.space.s5 })
        Column() {
          Text('开始')
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandDeep)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(Theme.colors().brandAccent)
            .borderRadius(Theme.radius.pill)
        }
        .padding({ right: Theme.space.s4 })
      }
      .width('100%')
    }
    .width('100%')
    .height(112)
    .onClick(() => this.onTap())
  }
}

@Component
export struct CareerRecommendCard {
  @Prop item: CourseItem = new CourseItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: 0 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(CareerMedia.cover(this.item.coverKey, this.item.category))
          .width(168)
          .height(112)
          .objectFit(ImageFit.Cover)
        Text('免费')
          .fontSize(Theme.type.overline)
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(Theme.colors().brandAccent)
          .borderRadius(Theme.radius.pill)
          .margin({ left: 8, top: 8 })
      }
      .width(168)
      .height(112)
      .clip(true)
      Column({ space: 4 }) {
        Text(this.item.category)
          .fontSize(Theme.type.overline)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .fontWeight(FontWeight.Medium)
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .height(40)
        Text(`${this.item.level} · ${this.item.duration}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
      }
      .width(168)
      .padding(Theme.space.s3)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    }
    .width(168)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 12,
      color: 'rgba(26,42,108,0.08)',
      offsetY: 4,
      offsetX: 0
    })
    .onClick(() => this.onTap())
  }
}

@Component
export struct CareerCategoryTile {
  @Prop tile: CategoryTileItem = new CategoryTileItem()
  onTap: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(CareerMedia.cover(this.tile.coverKey, this.tile.key))
        .width('100%')
        .height(96)
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height(96)
        .linearGradient({
          angle: 180,
          colors: [[0x00000000, 0.2], [0xCC1A2A6C, 1.0]]
        })
      Column({ space: 2 }) {
        Text(this.tile.label)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text('点击进入')
          .fontSize(Theme.type.overline)
          .fontColor('rgba(255,255,255,0.85)')
      }
      .padding(Theme.space.s3)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .height(96)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .onClick(() => this.onTap())
  }
}

@Component
export struct CareerTeacherCard {
  @Prop item: TeacherItem = new TeacherItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Image(CareerMedia.cover(this.item.coverKey, '职场技能'))
        .width(120)
        .height(120)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
      Text(this.item.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .width(120)
      Text(this.item.specialty)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .width(120)
      if (this.item.years > 0) {
        Text(`${this.item.years} 年经验`)
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().brandAccent)
      }
    }
    .width(120)
    .onClick(() => this.onTap())
  }
}

@Component
export struct CareerArticleRow {
  @Prop item: ArticleItem = new ArticleItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image(CareerMedia.cover('', this.item.category))
          .width(72)
          .height(72)
          .borderRadius(Theme.radius.sm)
          .objectFit(ImageFit.Cover)
        if (this.item.readMinutes > 0) {
          Text(`${this.item.readMinutes}分`)
            .fontSize(Theme.type.overline)
            .fontColor('#FFFFFF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('rgba(26,42,108,0.72)')
            .borderRadius(Theme.radius.xs)
            .position({ x: 4, y: 48 })
        }
      }
      Column({ space: 4 }) {
        Text(this.item.category)
          .fontSize(Theme.type.overline)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
        Text(this.item.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}

@Component
export struct CareerActivityRow {
  @Prop item: ActivityItem = new ActivityItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(CareerMedia.cover(this.item.coverKey, this.item.type))
          .width(88)
          .height(88)
          .borderRadius(Theme.radius.md)
          .objectFit(ImageFit.Cover)
        if (this.item.type.length > 0) {
          Text(this.item.type)
            .fontSize(Theme.type.overline)
            .fontColor('#FFFFFF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('rgba(26,42,108,0.78)')
            .borderRadius(Theme.radius.xs)
            .margin(6)
        }
      }
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
        Text(`${this.item.startAt} · ${this.item.venue}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
        Text(this.item.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}

@Component
export struct CareerSectionHeader {
  @Prop title: string = ''
  @Prop action: string = ''
  onAction: () => void = () => {}

  build() {
    Row() {
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Blank()
      if (this.action.length > 0) {
        Text(this.action)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .fontWeight(FontWeight.Medium)
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
  }
}

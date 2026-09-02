import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { ItemRow, ProgressTrack } from '../shop/ShoppingCards'
import { ShoppingMedia } from '../../services/ShoppingMedia'
import { CategorySuggest } from '../../services/CategorySuggest'
import { ShoppingService } from '../../services/ShoppingService'
import { ShoppingLocalStore } from '../../services/ShoppingLocalStore'
import { ShoppingItem, ShoppingList } from '../../models/ShoppingModels'
import { ShoppingCatalog } from '../../services/ShoppingCatalog'

class CategoryGroup {
  cat: string = ''
  items: ShoppingItem[] = []
}

@Component
export struct ListDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onListChange') listId: string = ''
  @Prop @Watch('onListChange') refreshToken: number = 0
  @State list: ShoppingList = new ShoppingList()
  @State items: ShoppingItem[] = []
  @State confirmDelete: boolean = false
  @State budgetText: string = ''
  @State sortMode: string = '分类'
  @State tagFilter: string = '全部'
  @State memberText: string = ''
  @State doneNum: number = 0
  @State totalNum: number = 0
  @State estNum: number = 0
  @State paidNum: number = 0
  onClose: () => void = () => {}
  onAddItem: () => void = () => {}
  onRemind: () => void = () => {}
  onAisle: () => void = () => {}
  onDeleted: () => void = () => {}
  onShare: (text: string) => void = () => {}
  onDuplicated: (id: string) => void = () => {}
  onDataChange: () => void = () => {}
  onOpenItem: (itemId: string) => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onListChange(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const found = await ShoppingService.findList(this.listId)
    if (found !== undefined) {
      this.list = found
      this.budgetText = found.budgetYuan
      this.memberText = found.members
    }
    this.items = await ShoppingService.items(this.listId)
    this.syncMetrics()
  }

  private syncMetrics(): void {
    this.totalNum = this.items.length
    this.doneNum = ShoppingService.doneCount(this.items)
    this.estNum = ShoppingService.priceSum(this.items)
    this.paidNum = ShoppingService.paidSum(this.items)
  }

  private visibleItems(): ShoppingItem[] {
    const tagged = ShoppingService.filterByTag(this.items, this.tagFilter)
    if (this.sortMode === '分类') {
      return tagged
    }
    return ShoppingService.sortItems(tagged, this.sortMode)
  }

  private grouped(cat: string): ShoppingItem[] {
    const out: ShoppingItem[] = []
    for (const it of ShoppingService.filterByTag(this.items, this.tagFilter)) {
      if (it.category === cat) {
        out.push(it)
      }
    }
    return out
  }

  private categoryGroups(): CategoryGroup[] {
    const out: CategoryGroup[] = []
    const used: string[] = []
    const order = CategorySuggest.categories()
    for (const cat of order) {
      const items: ShoppingItem[] = this.grouped(cat)
      if (items.length > 0) {
        const g = new CategoryGroup()
        g.cat = cat
        g.items = items
        out.push(g)
        used.push(cat)
      }
    }
    for (const it of this.items) {
      const cat = it.category.length > 0 ? it.category : '其他'
      if (used.indexOf(cat) >= 0) {
        continue
      }
      used.push(cat)
      const g = new CategoryGroup()
      g.cat = cat
      g.items = this.grouped(cat)
      if (g.items.length > 0) {
        out.push(g)
      }
    }
    return out
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('分享')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .onClick(() => this.onShare(ShoppingService.shareText(this.list, this.items)))
        Text(this.list.starred ? '已收藏' : '收藏')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .margin({ left: 12 })
          .onClick((): void => {
            void ShoppingService.toggleStar(this.listId).then(() => {
              void this.reload()
              this.onDataChange()
            })
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(ShoppingMedia.cover(this.list.coverKey.length > 0 ? this.list.coverKey : 'home_hero'))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 180,
                colors: [['rgba(8,42,90,0.08)', 0], ['rgba(8,42,90,0.78)', 1]]
              })
              .borderRadius(Theme.radius.xl)
            Column({ space: 6 }) {
              Text(this.list.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(`${this.totalNum} 项 · ${this.doneNum} 已完成 · ${this.list.status === 'done' ? '已完成' : '进行中'}`)
                .fontSize(Theme.type.footnote)
                .fontColor('#FFFFFF')
            }
            .padding(18)
          }
          .width('100%')

          Column({ space: 12 }) {
            Text('完成进度')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
            ProgressTrack({ done: this.doneNum, total: this.totalNum })
            Text(`预估 ${this.estNum} 元 · 实付 ${this.paidNum} 元` +
              (this.list.budgetYuan.length > 0 ? ` / 预算 ${this.list.budgetYuan} 元` : ''))
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
            TextInput({ text: this.budgetText, placeholder: '本次预算（元，可选）' })
              .height(44)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 12, right: 12 })
              .onChange((v: string) => { this.budgetText = v })
            Text('保存预算')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
              .onClick((): void => {
                void ShoppingService.setListBudget(this.listId, this.budgetText.trim()).then(() => {
                  void this.reload()
                  this.onDataChange()
                })
              })
            Text('清单分类')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(ShoppingCatalog.listKinds(), (k: string) => {
                Text(k)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.list.kind === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 6, bottom: 6 })
                  .backgroundColor(this.list.kind === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    void ShoppingService.setListKind(this.listId, k).then(() => {
                      void this.reload()
                      this.onDataChange()
                    })
                  })
              }, (k: string) => k)
            }
            .width('100%')
            Text('排序 / 标签筛选')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
            Row({ space: 8 }) {
              ForEach(ShoppingCatalog.sortModes(), (m: string) => {
                Text(m)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.sortMode === m ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.sortMode === m ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => { this.sortMode = m })
              }, (m: string) => m)
            }
            .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              Text('全部')
                .fontSize(Theme.type.caption)
                .fontColor(this.tagFilter === '全部' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .margin({ right: 6, bottom: 6 })
                .backgroundColor(this.tagFilter === '全部' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.tagFilter = '全部' })
              ForEach(ShoppingCatalog.itemTags(), (t: string) => {
                Text(t)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.tagFilter === t ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 6, bottom: 6 })
                  .backgroundColor(this.tagFilter === t ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => { this.tagFilter = t })
              }, (t: string) => t)
            }
            .width('100%')
            TextInput({ text: this.memberText, placeholder: '家庭协作：家人昵称，逗号分隔，如 妈妈,爸爸' })
              .height(44)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 12, right: 12 })
              .onChange((v: string) => { this.memberText = v })
            Text('保存协作成员')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
              .onClick((): void => {
                void ShoppingService.setListMembers(this.listId, this.memberText.trim()).then(() => {
                  void this.reload()
                  this.onDataChange()
                })
              })
            Text(this.list.summary.length > 0 ? this.list.summary : '逐项勾选，出门更从容。')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.xl)

          if (this.items.length === 0) {
            AppEmpty({
              title: '还没有物品',
              description: '添加第一件想买的东西',
              actionLabel: '添加物品',
              onAction: () => this.onAddItem()
            })
          } else if (this.sortMode === '分类') {
            ForEach(this.categoryGroups(), (g: CategoryGroup) => {
              Column({ space: 4 }) {
                Text(g.cat)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                  .width('100%')
                  .padding({ top: 8 })
                ForEach(g.items, (it: ShoppingItem) => {
                  ItemRow({
                    title: it.title,
                    extra: ShoppingService.extraLine(it),
                    done: it.completed,
                    detailEnabled: true,
                    onOpen: (): void => { this.onOpenItem(it.id) },
                    onToggle: (): void => {
                      const next: ShoppingItem[] = []
                      for (const row of this.items) {
                        const copy = ShoppingLocalStore.cloneItem(row)
                        if (copy.id === it.id) {
                          copy.completed = !copy.completed
                        }
                        next.push(copy)
                      }
                      this.items = next
                      this.syncMetrics()
                      void ShoppingService.toggleItem(it).then(() => {
                        void this.reload()
                        this.onDataChange()
                      })
                    }
                  })
                }, (it: ShoppingItem) => `${it.id}_${it.completed ? '1' : '0'}`)
              }
              .width('100%')
              .padding({ left: 8, right: 8 })
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.xl)
            }, (g: CategoryGroup) => g.cat)
          } else {
            Column({ space: 4 }) {
              ForEach(this.visibleItems(), (it: ShoppingItem) => {
                ItemRow({
                  title: it.title,
                  extra: ShoppingService.extraLine(it),
                  done: it.completed,
                  detailEnabled: true,
                  onOpen: (): void => { this.onOpenItem(it.id) },
                  onToggle: (): void => {
                    const next: ShoppingItem[] = []
                    for (const row of this.items) {
                      const copy = ShoppingLocalStore.cloneItem(row)
                      if (copy.id === it.id) {
                        copy.completed = !copy.completed
                      }
                      next.push(copy)
                    }
                    this.items = next
                    this.syncMetrics()
                    void ShoppingService.toggleItem(it).then(() => {
                      void this.reload()
                      this.onDataChange()
                    })
                  }
                })
              }, (it: ShoppingItem) => `${it.id}_${it.completed ? '1' : '0'}`)
            }
            .width('100%')
            .padding({ left: 8, right: 8 })
            .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.xl)
          }

          AppButton({ label: '添加物品', onTap: () => this.onAddItem() })
          AppButton({ label: '卖场路线', variant: 'secondary', onTap: () => this.onAisle() })
          AppButton({ label: '智慧提醒', variant: 'secondary', onTap: () => this.onRemind() })
          AppButton({
            label: '再买一次',
            variant: 'secondary',
            onTap: (): void => {
              void ShoppingService.duplicateList(this.listId).then((row) => {
                if (row !== undefined) {
                  this.onDuplicated(row.id)
                }
              })
            }
          })
          if (this.list.status === 'done') {
            AppButton({
              label: '重新开启',
              variant: 'ghost',
              onTap: (): void => {
                void ShoppingService.reopenList(this.listId).then(() => {
                  void this.reload()
                  this.onDataChange()
                })
              }
            })
          } else if (this.totalNum > 0 && this.doneNum === this.totalNum) {
            AppButton({
              label: '标记为已完成',
              variant: 'ghost',
              onTap: (): void => {
                void ShoppingService.setListStatus(this.listId, 'done').then(() => {
                  void this.reload()
                  this.onDataChange()
                })
              }
            })
          }
          AppButton({
            label: this.confirmDelete ? '再点一次确认删除' : '删除清单',
            variant: 'ghost',
            onTap: (): void => {
              if (!this.confirmDelete) {
                this.confirmDelete = true
                return
              }
              void ShoppingService.deleteList(this.listId).then(() => this.onDeleted())
            }
          })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}

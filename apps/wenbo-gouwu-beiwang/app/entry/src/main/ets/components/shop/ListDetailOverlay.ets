import { ListDetailPane } from '../detail/ListDetailPane'

@Component
export struct ListDetailOverlay {
  @Prop listId: string = ''
  @Prop refreshToken: number = 0
  onClose: () => void = () => {}
  onAddItem: () => void = () => {}
  onRemind: () => void = () => {}
  onAisle: () => void = () => {}
  onDeleted: () => void = () => {}
  onShare: (text: string) => void = () => {}
  onDuplicated: (id: string) => void = () => {}
  onDataChange: () => void = () => {}
  onOpenItem: (itemId: string) => void = () => {}

  build() {
    ListDetailPane({
      listId: this.listId,
      refreshToken: this.refreshToken,
      onClose: () => this.onClose(),
      onAddItem: () => this.onAddItem(),
      onRemind: () => this.onRemind(),
      onAisle: () => this.onAisle(),
      onDeleted: () => this.onDeleted(),
      onShare: (text: string) => this.onShare(text),
      onDuplicated: (id: string) => this.onDuplicated(id),
      onDataChange: () => this.onDataChange(),
      onOpenItem: (itemId: string) => this.onOpenItem(itemId)
    })
  }
}
